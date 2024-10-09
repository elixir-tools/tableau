defmodule Mix.Tasks.Tableau.Build do
  @shortdoc "Builds the site"

  @moduledoc "Task to build the tableau site"
  use Mix.Task

  alias Tableau.Graph.Nodable

  require Logger

  @config :tableau |> Application.compile_env(:config, %{}) |> Map.new()

  @impl Mix.Task
  def run(argv) do
    Application.ensure_all_started(:telemetry)
    {:ok, config} = Tableau.Config.new(@config)
    token = %{site: %{config: config}}
    Mix.Task.run("app.start", ["--preload-modules"])

    {opts, _argv} = OptionParser.parse!(argv, strict: [out: :string])

    out = Keyword.get(opts, :out, "_site")

    mods = :code.all_available()

    token = mods |> pre_build_extensions() |> run_extensions(token)

    mods = :code.all_available()
    graph = Tableau.Graph.new(mods)

    File.mkdir_p!(out)

    pages =
      for mod <- Graph.vertices(graph), {:ok, :page} == Nodable.type(mod) do
        {mod, Map.new(Nodable.opts(mod) || [])}
      end

    {page_mods, just_pages} = Enum.unzip(pages)

    token = put_in(token.site[:pages], just_pages)

    token = mods |> pre_write_extensions() |> run_extensions(token)

    for {mod, page} <- Enum.zip(page_mods, token.site.pages) do
      content = Tableau.Document.render(graph, mod, token, page)
      permalink = Nodable.permalink(mod)
      dir = Path.join(out, permalink)

      File.mkdir_p!(dir)

      File.write!(Path.join(dir, "index.html"), content)
    end

    if File.exists?(config.include_dir) do
      File.cp_r!(config.include_dir, out)
    end

    token = run_extensions(post_write_extensions(mods), token)

    token
  end

  defp validate_config(config_mod, raw_config) do
    if Code.ensure_loaded?(config_mod) do
      config_mod.new(raw_config)
    else
      {:ok, raw_config}
    end
  end

  defp pre_build_extensions(modules) do
    extensions =
      for {mod, _, _} <- modules,
          mod = Module.concat([to_string(mod)]),
          match?({:ok, :pre_build}, Tableau.Extension.type(mod)) do
        mod
      end

    Enum.sort_by(extensions, & &1.__tableau_extension_priority__())
  end

  defp pre_write_extensions(modules) do
    extensions =
      for {mod, _, _} <- modules,
          mod = Module.concat([to_string(mod)]),
          match?({:ok, :pre_write}, Tableau.Extension.type(mod)) do
        mod
      end

    Enum.sort_by(extensions, & &1.__tableau_extension_priority__())
  end

  defp post_write_extensions(modules) do
    extensions =
      for {mod, _, _} <- modules,
          mod = Module.concat([to_string(mod)]),
          match?({:ok, :post_write}, Tableau.Extension.type(mod)) do
        mod
      end

    Enum.sort_by(extensions, & &1.__tableau_extension_priority__())
  end

  defp run_extensions(extensions, token) do
    for module <- extensions, reduce: token do
      token ->
        config_mod = Module.concat([module, Config])

        raw_config =
          :tableau |> Application.get_env(module, %{enabled: true}) |> Map.new()

        if raw_config[:enabled] do
          {:ok, config} = validate_config(config_mod, raw_config)

          {:ok, key} = Tableau.Extension.key(module)

          token = put_in(token[key], config)

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
