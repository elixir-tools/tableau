defmodule Tableau.Router do
  use Plug.Router

  plug Plug.Logger, log: :debug
  plug Plug.Static, at: "/", only: [".css"], from: "priv/static"
  plug :append_slash

  plug :match
  plug :dispatch

  match _ do
    file = "_site" <> conn.request_path <> "index.html"

    conn = put_resp_header(conn, "content-type", "text/html")

    try do
      send_resp(conn, 200, File.read!(file))
    rescue
      _ ->
        send_resp(
          conn,
          404,
          ~S|<!DOCTYPE html><html lang="en"><head></head><body>Not Found</body></html>|
        )
    end
  end

  defp append_slash(conn, _) do
    path =
      if String.ends_with?(conn.request_path, "/") do
        conn.request_path
      else
        conn.request_path <> "/"
      end

    %{conn | request_path: path}
  end
end
