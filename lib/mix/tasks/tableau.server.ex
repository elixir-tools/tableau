defmodule Mix.Tasks.Tableau.Server do
  @shortdoc "Starts the tableau dev server"

  @moduledoc "Starts the tableau dev server"
  use Mix.Task

  require Logger

  @impl Mix.Task
  def run(_args) do
    Application.put_env(:tableau, :server, true)
    Code.put_compiler_option(:ignore_module_conflict, true)

    Logger.debug("server started on http://localhost:4999#{basepath()}")

    Mix.Task.run("app.start", ["--preload-modules"])

    Mix.Tasks.Run.run(["--no-halt"])
  end

  defp basepath do
    case Application.get_env(:tableau, :config)[:base_path] do
      "" -> ""
      path -> Path.join("/", path)
    end
  end
end
