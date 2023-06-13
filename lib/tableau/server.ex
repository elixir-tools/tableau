defmodule Tableau.Server do
  @moduledoc false
  def child_spec(_) do
    Supervisor.child_spec(
      {Plug.Cowboy,
       scheme: :http, plug: Tableau.Router, options: [dispatch: dispatch(), port: 4999]},
      []
    )
  end

  defp dispatch() do
    [
      {:_,
       [
         {"/ws", Tableau.Websocket, []},
         {:_, Plug.Cowboy.Handler, {Tableau.Router, []}}
       ]}
    ]
  end
end
