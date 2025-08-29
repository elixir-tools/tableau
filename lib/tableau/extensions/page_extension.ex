defmodule Tableau.PageExtension do
  @moduledoc """
  Content files (with YAML frontmatter) in the configured pages directory will be automatically compiled into Tableau pages.

  Certain frontmatter keys are required and all keys are passed as options to the `Tableau.Page`.

  ## Options

  Frontmatter is compiled with `yaml_elixir` and all keys are converted to atoms.

  * `:title` - The title of the page
  * `:permalink` - The permalink of the page.
  * `:layout` - A string representation of a Tableau layout module.
  * `:converter` - A string representation of a converter module. (optional)

  ## Example

  ```yaml
  id: "GettingStarted"
  title: "Getting Started"
  permalink: "/docs/:title"
  layout: "ElixirTools.PageLayout"
  converter: "MyConverter"
  ```

  ## Permalink

  The permalink is a string with colon prefixed template variables.

  These variables will be swapped with the corresponding YAML Frontmatter key, with the result being piped through `to_string/1`.

  ## Configuration

  - `:enabled` - boolean - Extension is active or not.
  - `:dir` - string or list of strings - Directories to scan for markdown files. Defaults to `_pages`
  - `:permalink` - string - Default output path for pages. Accepts `:title` as a replacement keyword, replaced with the page's provided title. If a page has a `:permalink` provided, that will override this value _for that page_.
  - `:layout` - string - Elixir module providing page layout for pages. Default is nil.

  ### Example

  ```elixir
  config :tableau, Tableau.PageExtension,
    enabled: true,
    dir: "_docs",
    permalink: "/docs/:title",
    layout: "MyApp.PageLayout"
  ```

  ## Content formats

  If you're interested in authoring your content in something other than markdown (or you want to use a different markdown parser), you can configure
  a converter for your format in the global configuration.

  Currently the `Tableau.MDExConverter` is the only builtin converter, but you are free to write your own!

  ```elixir
  # config/config.exs

  import Config

  config :tableau, :config,
    converters: [
      md: Tableau.MDExConverter,
      adoc: MySite.AsciiDocConverter
    ],
  ```

  As noted above, a converter can be overridden on a specific page, using the frontmatter `:converter` key.
  """

  use Tableau.Extension, key: :pages, priority: 100

  import Schematic

  alias Tableau.Extension.Common

  @impl Tableau.Extension
  def config(input) do
    unify(
      map(%{
        optional(:enabled, true) => bool(),
        optional(:dir, "_pages") => oneof([list(str()), str()]),
        optional(:permalink) => str(),
        optional(:layout) => oneof([str(), atom()])
      }),
      input
    )
  end

  @impl Tableau.Extension
  def pre_build(token) do
    %{site: %{config: %{converters: converters}}, extensions: %{pages: %{config: config}}} = token

    exts = Enum.map_join(converters, ",", fn {ext, _} -> to_string(ext) end)

    pages =
      config.dir
      |> List.wrap()
      |> Enum.flat_map(fn path ->
        path
        |> Path.join("**/*.{#{exts}}")
        |> Common.paths()
      end)
      |> Common.entries(fn entry ->
        %{
          path: path,
          front_matter: front_matter,
          pre_convert_body: body,
          ext: ext
        } = entry

        build(path, front_matter, body, config, fn assigns ->
          converter =
            case front_matter[:converter] do
              nil -> converters[ext]
              converter -> Module.concat([converter])
            end

          converter.convert(path, front_matter, body, assigns)
        end)
      end)

    {:ok, Map.put(token, :pages, pages)}
  end

  @impl Tableau.Extension
  def pre_render(token) do
    graph =
      Tableau.Graph.insert(
        token.graph,
        Enum.map(token.pages, fn page ->
          %Tableau.Page{parent: page.layout, permalink: page.permalink, template: page.renderer, opts: page}
        end)
      )

    {:ok, Map.put(token, :graph, graph)}
  end

  defp build(filename, front_matter, body, pages_config, renderer) do
    front_matter
    |> Map.put(:__tableau_page_extension__, true)
    |> Map.put(:body, body)
    |> Map.put(:file, filename)
    |> Map.put(:renderer, renderer)
    |> Map.put(:layout, Module.concat([front_matter[:layout] || pages_config.layout]))
    |> Common.build_permalink(pages_config)
  end
end
