defmodule TableauDevServer.Server do
  @moduledoc false
  def child_spec(_) do
    port = if Mix.env() == :dev, do: 4999, else: 4998

    Supervisor.child_spec(
      {Bandit, scheme: :http, plug: TableauDevServer.Router, port: port},
      []
    )
  end
end
