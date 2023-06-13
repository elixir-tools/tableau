defmodule Tableau.Application do
  @moduledoc false

  require Logger

  use Application

  @impl true
  def start(_type, _args) do
    children = [Tableau.ServerSupervisor]

    opts = [strategy: :one_for_one, name: Tableau.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
