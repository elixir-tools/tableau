defmodule Tableau.Router do
  use Plug.Router

  require Logger

  alias Tableau.Store

  @not_found ~S|<!DOCTYPE html><html lang="en"><head></head><body>Not Found</body></html>|

  plug Plug.Logger, log: :debug
  plug Plug.Static, at: "/", only: [".css"], from: "priv/static"
  plug :recompile
  plug :add_index

  plug :match
  plug :dispatch

  match _ do
    site = Store.fetch()

    site.posts
    |> Map.merge(site.pages)
    |> Map.fetch!(URI.decode(conn.request_path))
    |> Tableau.Renderable.render()

    try do
      conn
      |> put_resp_header("content-type", "text/html")
      |> send_resp(200, File.read!(conn.private.tableau_file))
    rescue
      exception ->
        Logger.error(inspect(exception))

        send_resp(conn, 404, @not_found)
    end
  end

  defp recompile(conn, _) do
    Mix.Task.rerun("compile.elixir", [])

    conn
  end

  defp add_index(conn, _) do
    path_info =
      if List.last(conn.path_info) == "index.html" do
        conn.path_info
      else
        rest = Enum.reverse(conn.path_info)

        Enum.reverse(["index.html" | rest])
      end

    file = Enum.join(["_site" | path_info], "/") |> URI.decode()

    conn |> put_private(:tableau_file, file)
  end
end
