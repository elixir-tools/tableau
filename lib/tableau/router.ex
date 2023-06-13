defmodule Tableau.Router do
  use Plug.Router, init_mode: :runtime

  require Logger
  import Tableau.Strung

  @not_found ~g'''
  <!DOCTYPE html><html lang="en"><head></head><body>Not Found</body></html>
  '''html

  plug :recompile
  plug :rerender

  plug Tableau.IndexHtml
  plug Plug.Static, at: "/", from: "_site", cache_control_for_etags: "no-cache"

  plug :match
  plug :dispatch

  match _ do
    Logger.error("File not found: #{conn.request_path}")

    send_resp(conn, 404, @not_found)
  end

  defp recompile(conn, _) do
    Tableau.CodeReloader.reload()
    conn
  end

  defp rerender(conn, _) do
    out = "_site"
    mods = :code.all_available()
    graph = Tableau.Graph.new(mods)
    File.mkdir_p!(out)

    for mod <- Graph.vertices(graph), {:ok, :page} == Tableau.Graph.Node.type(mod) do
      content = Tableau.Document.render(graph, mod, %{site: %{}})
      permalink = mod.__tableau_permalink__()
      dir = Path.join(out, permalink)

      File.mkdir_p!(dir)

      File.write!(Path.join(dir, "index.html"), content, [:sync])
    end

    conn
  end
end
