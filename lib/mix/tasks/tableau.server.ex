defmodule Mix.Tasks.Tableau.Server do
  use Mix.Task

  require Logger

  @moduledoc "Starts the tableau dev server"
  @shortdoc "Starts the tableau dev server"

  @impl Mix.Task
  def run(_args) do
    Application.put_env(:tableau, :server, true)
    Code.put_compiler_option(:ignore_module_conflict, true)

    Logger.debug("server started on http://localhost:4999")

    Mix.Task.run("app.start", ["--preload-modules"])

    Mix.Tasks.Run.run(["--no-halt"])
  end
end
