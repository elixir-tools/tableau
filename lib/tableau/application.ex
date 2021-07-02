defmodule Tableau.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    server_children =
      if Application.get_env(:tableau, :server) do
        reloader_opts =
          Application.get_env(:tableau, :reloader, dirs: ["./lib/pages/", "./_posts"])

        [
          {Plug.Cowboy,
           scheme: :http, plug: Tableau.Router, options: [dispatch: dispatch(), port: 4999]},
          {Registry, name: Tableau.LiveReloadRegistry, keys: :duplicate},
          %{
            id: FileSystem,
            start:
              {FileSystem, :start_link,
               [Keyword.merge(reloader_opts, name: :tableau_file_watcher, latency: 0)]}
          },
          Tableau.Watcher
        ]
      else
        []
      end

    children = server_children ++ [{Tableau.Store, name: Tableau.Store}]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tableau.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dispatch() do
    [
      {:_,
       [
         {"/ws", Tableau.LiveReload, []},
         {:_, Plug.Cowboy.Handler, {Tableau.Router, []}}
       ]}
    ]
  end
end
