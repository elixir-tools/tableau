defmodule Tableau.LiveReload do
  @behaviour :cowboy_websocket

  def init(request, state) do
    {:cowboy_websocket, request, state}
  end

  def websocket_init(state) do
    Registry.register(Tableau.LiveReloadRegistry, :reload, :reload)

    {:ok, state}
  end

  def websocket_handle({:text, _text}, state) do
    {:reply, {:text, "pong"}, state}
  end

  def websocket_handle({:ping, _text}, state) do
    {:reply, {:pong, "PONG"}, state}
  end

  def websocket_info(:reload, state) do
    {:reply, {:text, "reload"}, state}
  end
end
