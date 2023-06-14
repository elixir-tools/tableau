defmodule Mix.Tasks.Tableau.Build do
  use Mix.Task

  require Logger

  @moduledoc "Task to build the tableau site"
  @shortdoc "Builds the site"

  @impl Mix.Task
  def run(argv) do
    Mix.Task.run("app.start", ["--preload-modules"])

    {opts, _argv} = OptionParser.parse!(argv, strict: [out: :string])

    out = Keyword.get(opts, :out, "_site")
    mods = :code.all_available()
    graph = Tableau.Graph.new(mods)
    File.mkdir_p!(out)

    for mod <- Graph.vertices(graph), {:ok, :page} == Tableau.Graph.Node.type(mod) do
      content = Tableau.Document.render(graph, mod, %{site: %{}})
      permalink = mod.__tableau_permalink__()
      dir = Path.join(out, permalink)

      File.mkdir_p!(dir)

      File.write!(Path.join(dir, "index.html"), content)
    end
  end
end
