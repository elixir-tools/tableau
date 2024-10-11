defmodule TableauDevServer.Application do
  @moduledoc false

  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    children = [TableauDevServer.ServerSupervisor]

    opts = [strategy: :one_for_one, name: TableauDevServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
