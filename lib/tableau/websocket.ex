defmodule Tableau.Websocket do
  @behaviour :cowboy_websocket
  # @reloader_opts Application.compile_env(:tableau, :reloader, patterns: [])

  require Logger

  def init(request, state) do
    {:cowboy_websocket, request, state}
  end

  def websocket_init(state) do
    # :ok = Tableau.LiveReload.init(name: :tableau_file_watcher)

    {:ok, state}
  end

  def websocket_handle({:text, _text}, state) do
    {:reply, {:text, "pong"}, state}
  end

  def websocket_handle({:ping, _text}, state) do
    {:reply, {:pong, "PONG"}, state}
  end

  def websocket_info({:reload, _asset_type}, state) do
    {:reply, {:text, "reload"}, state}
  end

  def websocket_info({:file_event, _watcher_pid, {_path, _event}} = _file_event, state) do
    # Tableau.LiveReload.reload!(file_event, patterns: @reloader_opts[:patterns])

    {:ok, state}
  end

  def websocket_info(message, state) do
    Logger.warn("Unhandled message: #{inspect(message)}")

    {:ok, state}
  end
end
