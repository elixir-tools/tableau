defmodule Mix.Tasks.Tableau.Build do
  use Mix.Task

  require Logger

  @moduledoc "Task to build the tableau site"
  @shortdoc "Builds the site"

  @include_dir Application.compile_env(:tableau, :include, "extra")

  @impl Mix.Task
  def run(argv) do
    Mix.Task.run("app.start", ["--preload-modules"])

    {opts, _argv} = OptionParser.parse!(argv, strict: [out: :string])

    out = Keyword.get(opts, :out, "_site")

    mods = :code.all_available()

    for module <- pre_build_extensions(mods) do
      with :error <- module.run(%{site: %{}}) do
        Logger.error("#{inspect(module)} failed to run")
      end
    end

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

    if File.exists?(@include_dir) do
      File.cp_r!(@include_dir, out)
    end
  end

  defp pre_build_extensions(modules) do
    for {mod, _, _} <- modules,
        mod = Module.concat([to_string(mod)]),
        match?({:ok, :pre_build}, Tableau.Extension.type(mod)) do
      mod
    end
    |> Enum.sort_by(& &1.__tableau_extension_priority__())
  end
end
