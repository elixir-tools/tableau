defmodule Tableau.Application do
  @moduledoc false

  require Logger

  use Application

  @impl true
  def start(_type, _args) do
    file_system_opts =
      Keyword.merge([dirs: [Path.absname("")]], name: :tableau_file_watcher, latency: 0)

    children =
      if Application.get_env(:tableau, :server) do
        [
          %{
            id: FileSystem,
            start: {FileSystem, :start_link, [file_system_opts]}
          },
          {Plug.Cowboy,
           scheme: :http, plug: Tableau.Router, options: [dispatch: dispatch(), port: 4999]},
          Tableau.CodeReloader,
          {Tableau.Store, name: Tableau.Store}
        ] ++ asset_children()
      else
        []
      end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tableau.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def asset_children do
    for conf <- Application.get_env(:tableau, :assets, []) do
      {Tableau.Assets, conf}
    end
  end

  defp dispatch do
    [
      {:_,
       [
         {"/ws", Tableau.Websocket, []},
         {:_, Plug.Cowboy.Handler, {Tableau.Router, []}}
       ]}
    ]
  end
end
