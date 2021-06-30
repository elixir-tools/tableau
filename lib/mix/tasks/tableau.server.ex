defmodule Mix.Tasks.Tableau.Server do
  use Mix.Task

  require Logger

  @moduledoc "Starts the tableau dev server"
  @shortdoc "Starts the tableau dev server"

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("tableau.build", [])

    Application.put_env(:tableau, :server, true)

    Logger.debug("server started on http://localhost:4999")

    Mix.Tasks.Run.run(["--no-halt"])
  end
end
