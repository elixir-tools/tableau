defmodule Mix.Tasks.Tableau.Build do
  @shortdoc "Builds the site"

  @moduledoc "Task to build the tableau site"
  use Mix.Task

  alias Tableau.Graph.Nodable

  require Logger

  @impl Mix.Task
  def run(argv) do
    Application.ensure_all_started(:telemetry)
    {:ok, config} = Tableau.Config.get()
    token = %{site: %{config: config}, graph: Graph.new()}
    Mix.Task.run("app.start", ["--preload-modules"])

    {opts, _argv} = OptionParser.parse!(argv, strict: [out: :string])

    out = opts[:out] || config.out_dir

    mods =
      :code.all_available()
      |> Task.async_stream(fn {mod, _, _} -> Module.concat([to_string(mod)]) end)
      |> Stream.map(fn {:ok, mod} -> mod end)
      |> Enum.to_list()

    {:ok, config} = Tableau.Config.get()
    token = Map.put(token, :extensions, %{})

    token = mods |> extensions_for(:pre_build) |> run_extensions(token)

    graph = Tableau.Graph.insert(token.graph, mods)

    File.mkdir_p!(out)

    pages =
      for mod <- Graph.vertices(graph), {:ok, :page} == Nodable.type(mod) do
        {mod, Map.new(Nodable.opts(mod) || [])}
      end

    token = put_in(token.site[:pages], Enum.map(pages, fn {_mod, page} -> page end))

    pages =
      pages
      |> Task.async_stream(fn {mod, page} ->
        try do
          content = Tableau.Document.render(graph, mod, token, page)
          permalink = Nodable.permalink(mod)

          Map.merge(page, %{body: content, permalink: permalink})
        rescue
          exception ->
            reraise TableauDevServer.BuildException, [page: page, exception: exception], __STACKTRACE__
        end
      end)
      |> Stream.map(fn
        {:ok, result} -> result
        {:exit, {exception, stacktrace}} -> reraise exception, stacktrace
      end)
      |> Enum.to_list()

    token = put_in(token.site[:pages], pages)

    token = mods |> extensions_for(:pre_write) |> run_extensions(token)

    for %{body: body, permalink: permalink} <- pages do
      file_path = build_file_path(out, permalink)
      dir = Path.dirname(file_path)

      File.mkdir_p!(dir)

      File.write!(file_path, body)
    end

    if File.exists?(config.include_dir) do
      File.cp_r!(config.include_dir, out)
    end

    token = mods |> extensions_for(:post_write) |> run_extensions(token)

    token
  end

  @file_extensions [".html"]
  defp build_file_path(out, permalink) do
    if Path.extname(permalink) in @file_extensions do
      Path.join(out, permalink)
    else
      Path.join([out, permalink, "index.html"])
    end
  end

  defp validate_config(module, raw_config) do
    if function_exported?(module, :config, 1) do
      module.config(raw_config)
    else
      {:ok, raw_config}
    end
  end

  defp extensions_for(modules, type) do
    extensions =
      for mod <- modules, Code.ensure_loaded?(mod), {:ok, type} == Tableau.Extension.type(mod) do
        mod
      end

    Enum.sort_by(extensions, & &1.__tableau_extension_priority__())
  end

  defp run_extensions(extensions, token) do
    for module <- extensions, reduce: token do
      token ->
        raw_config =
          Map.merge(
            %{enabled: Tableau.Extension.enabled?(module)},
            :tableau |> Application.get_env(module, %{}) |> Map.new()
          )

        if raw_config[:enabled] do
          {:ok, config} = validate_config(module, raw_config)

          {:ok, key} = Tableau.Extension.key(module)

          token = put_in(token.extensions[key], %{config: config})

          case module.run(token) do
            {:ok, token} ->
              token

            :error ->
              Logger.error("#{inspect(module)} failed to run")
              token
          end
        else
          token
        end
    end
  end
end
