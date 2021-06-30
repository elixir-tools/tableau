defmodule Tableau.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      if Application.get_env(:tableau, :server) do
        reloader_opts = Application.get_env(:tableau, :reloader, dirs: ["./lib/pages/", "./_posts"])

        [
          {Plug.Cowboy,
           scheme: :http, plug: Tableau.Router, options: [port: 4999]},
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

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tableau.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
