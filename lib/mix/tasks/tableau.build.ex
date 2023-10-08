defmodule Mix.Tasks.Tableau.Build do
  use Mix.Task

  require Logger

  @moduledoc "Task to build the tableau site"
  @shortdoc "Builds the site"

  @config Application.compile_env(:tableau, :config, %{}) |> Map.new()

  @impl Mix.Task
  def run(argv) do
    {:ok, config} = Tableau.Config.new(@config)
    site = %{config: config}
    Mix.Task.run("app.start", ["--preload-modules"])

    {opts, _argv} = OptionParser.parse!(argv, strict: [out: :string])

    out = Keyword.get(opts, :out, "_site")

    mods = :code.all_available()

    for module <- pre_build_extensions(mods) do
      with :error <- module.run(%{site: site}) do
        Logger.error("#{inspect(module)} failed to run")
      end
    end

    mods = :code.all_available()
    graph = Tableau.Graph.new(mods)
    File.mkdir_p!(out)

    pages =
      for mod <- Graph.vertices(graph), {:ok, :page} == Tableau.Graph.Node.type(mod) do
        {mod, Map.new(mod.__tableau_opts__() || [])}
      end

    {mods, pages} = Enum.unzip(pages)

    site = Map.put(site, :pages, pages)

    for mod <- mods do
      content = Tableau.Document.render(graph, mod, %{site: site})
      permalink = mod.__tableau_permalink__()
      dir = Path.join(out, permalink)

      File.mkdir_p!(dir)

      File.write!(Path.join(dir, "index.html"), content)
    end

    if File.exists?(config.include_dir) do
      File.cp_r!(config.include_dir, out)
    end
  end

  defp pre_build_extensions(modules) do
    for {mod, _, _} <- modules,
        mod = Module.concat([to_string(mod)]),
        match?({:ok, :pre_build}, Tableau.Extension.type(mod)),
        Tableau.Extension.enabled?(mod) do
      mod
    end
    |> Enum.sort_by(& &1.__tableau_extension_priority__())
  end
end
