defmodule TableauDevServer.Router do
  @moduledoc false
  use Plug.Router, init_mode: :runtime
  use Plug.Debugger

  require Logger

  @base_path Path.join("/", Application.compile_env(:tableau, [:config, :base_path], ""))
  @out_dir Application.compile_env(:tableau, [:config, :out_dir], "_site")

  @not_found ~s'''
  <!DOCTYPE html><html lang="en"><head></head><body>Not Found</body></html>
  '''

  plug :recompile
  plug :rerender

  plug TableauDevServer.IndexHtml
  plug Plug.Static, at: @base_path, from: @out_dir, cache_control_for_etags: "no-cache"

  plug :match
  plug :dispatch

  get "/ws/index.html" do
    conn
    |> WebSockAdapter.upgrade(TableauDevServer.Websocket, [], timeout: 60_000)
    |> halt()
  end

  match _ do
    Logger.error("File not found: #{conn.request_path}")

    send_resp(conn, 404, @not_found)
  end

  defp recompile(conn, _) do
    if conn.request_path == "/ws" do
      conn
    else
      case WebDevUtils.CodeReloader.reload() do
        {:error, errors} ->
          errors = Enum.filter(errors, &(&1.severity == :error))

          message =
            errors
            |> Enum.map_join("\n", & &1.message)
            |> String.replace(~r/\x1B\[[0-9;]*m/, "")

          stacktrace = List.first(errors).stacktrace

          reraise CompileError, [description: message], stacktrace

        _ ->
          conn
      end
    end
  end

  defp rerender(conn, _) do
    if conn.request_path != "/ws" do
      Mix.Task.rerun("tableau.build", ["--out", @out_dir])
    end

    conn
  end
end
