defmodule Tableau.Websocket do
  @moduledoc false
  @reloader_opts Application.compile_env(:tableau, :reloader, patterns: [])

  require Logger

  def init(_args) do
    :ok = WebDevUtils.LiveReload.init()
    {:ok, []}
  end

  def handle_in({"subscribe", [opcode: :text]}, state) do
    {:push, {:text, "subscribed"}, state}
  end

  def handle_info({:reload, _asset_type}, state) do
    {:push, {:text, "reload"}, state}
  end

  def handle_info({:file_event, _watcher_pid, {_path, _event}} = file_event, state) do
    WebDevUtils.LiveReload.reload!(file_event, patterns: @reloader_opts[:patterns])

    {:ok, state}
  end

  def handle_info(message, state) do
    Logger.warning("Unhandled message: #{inspect(message)}")

    {:ok, state}
  end
end
