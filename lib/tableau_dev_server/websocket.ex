defmodule TableauDevServer.Websocket do
  @moduledoc false
  require Logger

  def init(_args) do
    :ok = WebDevUtils.LiveReload.init()
    {:ok, %{reloader: Application.get_env(:tableau, :reloader, patterns: [])}}
  end

  def handle_in({"subscribe", [opcode: :text]}, state) do
    {:push, {:text, "subscribed"}, state}
  end

  def handle_info(:reload, state) do
    {:push, {:text, "reload"}, state}
  end

  def handle_info({:file_event, watcher_pid, {path, event}}, state) do
    WebDevUtils.LiveReload.reload!({:file_event, watcher_pid, {Path.relative_to_cwd(path), event}},
      patterns: state.reloader[:patterns]
    )

    {:ok, state}
  end

  def handle_info(message, state) do
    Logger.warning("Unhandled message: #{inspect(message)}")

    {:ok, state}
  end
end
