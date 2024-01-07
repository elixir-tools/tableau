defmodule Tableau.Router do
  @moduledoc false
  use Plug.Router, init_mode: :runtime

  import Tableau.Strung

  require Logger

  @base_path Path.join("/", Application.compile_env(:tableau, :config)[:base_path] || "")

  @not_found ~g'''
  <!DOCTYPE html><html lang="en"><head></head><body>Not Found</body></html>
  '''html

  plug :recompile
  plug :rerender

  plug Tableau.IndexHtml
  plug Plug.Static, at: @base_path, from: "_site", cache_control_for_etags: "no-cache"

  plug :match
  plug :dispatch

  get "/ws/index.html" do
    conn
    |> WebSockAdapter.upgrade(Tableau.Websocket, [], timeout: 60_000)
    |> halt()
  end

  match _ do
    Logger.error("File not found: #{conn.request_path}")

    send_resp(conn, 404, @not_found)
  end

  defp recompile(conn, _) do
    WebDevUtils.CodeReloader.reload()
    conn
  end

  defp rerender(conn, _) do
    Mix.Task.rerun("tableau.build", ["--out", "_site"])

    conn
  end
end
