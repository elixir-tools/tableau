defmodule Tableau.ServerSupervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    if Application.get_env(:tableau, :server) do
      children = [
        Tableau.ContentSupervisor,
        Tableau.FileSystem,
        Tableau.Server,
        Tableau.CodeReloader
      ]

      Supervisor.init(children ++ asset_children(), strategy: :one_for_one)
    else
      :ignore
    end
  end

  def asset_children() do
    for conf <- Application.get_env(:tableau, :assets, []) do
      {Tableau.Assets, conf}
    end
  end
end
