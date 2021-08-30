defmodule Tableau.Router do
  use Plug.Router, init_mode: :runtime

  require Logger

  alias Tableau.Store

  @not_found ~S|<!DOCTYPE html><html lang="en"><head></head><body>Not Found</body></html>|

  plug :recompile
  plug :rerender

  plug Tableau.IndexHtml
  plug Plug.Static, at: "/", from: "_site"

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
    Store.build(URI.decode(conn.request_path))

    conn
  end
end
