defmodule TableauDevServer.Router do
  @moduledoc false
  use Plug.Router, init_mode: :runtime

  require Logger

  alias TableauDevServer.TaskProxy

  @base_path Path.join("/", Application.compile_env(:tableau, [:config, :base_path], ""))

  @not_found ~s'''
  <!DOCTYPE html><html lang="en"><head></head><body>Not Found</body></html>
  '''

  plug :recompile
  plug :rerender

  plug TableauDevServer.IndexHtml
  plug Plug.Static, at: @base_path, from: "_site", cache_control_for_etags: "no-cache"

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

  defp recompile(%{request_path: "/ws"} = conn, _), do: conn

  defp recompile(conn, _) do
    WebDevUtils.CodeReloader.reload()
    conn
  end

  defp rerender(%{request_path: "/ws"} = conn, _), do: conn

  defp rerender(conn, _) do
    case task_build() do
      {:ok, _} ->
        conn

      {:error, output} ->
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(500, template(output))
        |> halt()
    end
  end

  defp task_build() do
    proxy_io(fn ->
      try do
        Mix.Task.rerun("tableau.build", ["--out", "_site"])
        :ok
      catch
        :exit, {:shutdown, 1} ->
        :error

        kind, reason ->
          IO.puts(Exception.format(kind, reason, __STACKTRACE__))
          :error
      end
    end)
  end

  defp proxy_io(fun) do
    original_gl = Process.group_leader()
    {:ok, proxy_gl} = TaskProxy.start()
    Process.group_leader(self(), proxy_gl)

    try do
      {fun.(), TaskProxy.stop(proxy_gl)}
    after
      Process.group_leader(self(), original_gl)
      Process.exit(proxy_gl, :kill)
    end
  end

  defp template(output) do
    """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="utf-8">
        <title>CompileError</title>
        <meta name="viewport" content="width=device-width">
        <style>
        html, body, td, input {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Roboto", "Oxygen", "Ubuntu", "Cantarell", "Fira Sans", "Droid Sans", "Helvetica Neue", sans-serif;
        }

        * {
            box-sizing: border-box;
        }

        html {
            font-size: 15px;
            line-height: 1.6;
            background: #fff;
            color: #000;
        }

        .heading-block {
            background: #f9f9fa;
        }

        .heading-block,
        .output-block {
            padding: 48px;
        }

        .code-block {
            margin: 0;
            font-size: .85em;
            line-height: 1.6;
            white-space: pre-wrap;
        }
        .exception-info > .error,
        .exception-info > .subtext {
            margin: 0;
            padding: 0;
        }

        .exception-info > .error {
            font-size: 1em;
            font-weight: 700;
            color: #FF6467;
        }

        .exception-info > .subtext {
            font-size: 1em;
            font-weight: 400;
            color: #a0b0c0;
        }

        </style>
    </head>
    <body>
        <div class="heading-block">
            <aside class="exception-logo"></aside>
            <header class="exception-info">
                <h5 class="error">Tableau Compilation error</h5>
                <h5 class="subtext">Console output is shown below.</h5>
            </header>
        </div>
        <div class="output-block">
            <pre class="code code-block">#{format_output(output)}</pre>
        </div>
    </body>
    </html>
    """
  end

  defp format_output(output) do
    IO.iodata_to_binary(output)
    |> String.trim()
    |> Plug.HTML.html_escape()
  end
end
