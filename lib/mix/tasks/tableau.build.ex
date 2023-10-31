defmodule Mix.Tasks.Tableau.Build do
  @shortdoc "Builds the site"

  @moduledoc "Task to build the tableau site"
  use Mix.Task

  require Logger

  @config :tableau |> Application.compile_env(:config, %{}) |> Map.new()

  @impl Mix.Task
  def run(argv) do
    {:ok, config} = Tableau.Config.new(@config)
    token = %{site: %{config: config}}
    Mix.Task.run("app.start", ["--preload-modules"])

    {opts, _argv} = OptionParser.parse!(argv, strict: [out: :string])

    out = Keyword.get(opts, :out, "_site")

    mods = :code.all_available()

    token =
      for module <- pre_build_extensions(mods), reduce: token do
        token ->
          config_mod = Module.concat([module, Config])

          raw_config =
            :tableau |> Application.get_env(module, %{}) |> Map.new()

          if raw_config[:enabled] do
            {:ok, config} =
              config_mod.new(raw_config)

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

    mods = :code.all_available()
    graph = Tableau.Graph.new(mods)
    File.mkdir_p!(out)

    pages =
      for mod <- Graph.vertices(graph), {:ok, :page} == Tableau.Graph.Node.type(mod) do
        {mod, Map.new(mod.__tableau_opts__() || [])}
      end

    {page_mods, pages} = Enum.unzip(pages)

    token = put_in(token.site[:pages], pages)

    for mod <- page_mods do
      content = Tableau.Document.render(graph, mod, token)
      permalink = mod.__tableau_permalink__()
      dir = Path.join(out, permalink)

      File.mkdir_p!(dir)

      File.write!(Path.join(dir, "index.html"), content)
    end

    if File.exists?(config.include_dir) do
      File.cp_r!(config.include_dir, out)
    end

    for module <- post_write_extensions(mods), reduce: token do
      token ->
        config_mod = Module.concat([module, Config])

        raw_config =
          :tableau |> Application.get_env(module, %{}) |> Map.new()

        if raw_config[:enabled] do
          {:ok, config} =
            config_mod.new(raw_config)

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

  defp pre_build_extensions(modules) do
    extensions =
      for {mod, _, _} <- modules,
          mod = Module.concat([to_string(mod)]),
          match?({:ok, :pre_build}, Tableau.Extension.type(mod)) do
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
end
