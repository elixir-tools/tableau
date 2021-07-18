defmodule Tableau.Watcher do
  use GenServer

  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(_args) do
    FileSystem.subscribe(:tableau_file_watcher)

    {:ok, %{}}
  end

  def handle_info({:file_event, _watcher_pid, {path, _event}}, state) do
    Logger.debug("🔫 Reload! 🔫")

    :ok = Tableau.Store.mark_stale(path)

    Registry.dispatch(Tableau.LiveReloadRegistry, :reload, fn entries ->
      for {pid, _} <- entries, do: send(pid, :reload)
    end)

    {:noreply, state}
  end

  def handle_info(message, state) do
    Logger.debug("Unhandled message: #{inspect(message)}")

    {:noreply, state}
  end
end
