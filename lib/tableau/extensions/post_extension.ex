defmodule Tableau.PostExtension do
  @moduledoc """
  Content files (with YAML frontmatter) in the configured posts directory will be automatically compiled into Tableau pages.

  All files in the directory are copied to the output directory, and if their filetype has a matching converter, they are converted.

  Certain frontmatter keys are required and all keys are passed as options to the `Tableau.Page`.

  ## Options

  Frontmatter is compiled with `yaml_elixir` and all keys are converted to atoms.

  * `:title` - The title of the post.
  * `:permalink` - The permalink of the post. `:title` will be replaced with the posts title and non alphanumeric characters removed. Optional.
  * `:date` - A string representation of a date time, parsed by `DateTimeParser`. Supports timezones.
  * `:layout` - A string representation of a Tableau layout module.
  * `:converter` - A string representation of a converter module. (optional)

  ## Example

  ```yaml
  id: "Update.Volume3"
  title: "The elixir-tools Update Vol. 3"
  permalink: "/news/:title"
  date: "~N[2023-09-19 01:00:00]"
  layout: "ElixirTools.PostLayout"
  converter: "MyConverter"
  ```

  ## Permalink

  The permalink is a string with colon prefixed template variables.

  These variables will be swapped with the corresponding YAML Frontmatter key, with the result being piped through `to_string/1`.

  In addition, there are `:year`, `:month`, and `:day` template variables.

  ## Configuration

  - `:enabled` - boolean - Extension is active or not.
  - `:dir` - string or list of strings - Directories to scan for markdown files. Defaults to `_posts`
  - `:future` - boolean - Show posts that have dates later than the current timestamp, or time at which the site is generated.
  - `:permalink` - string - Default output path for posts. Accepts `:title` as a replacement keyword, replaced with the post's provided title. If a post has a `:permalink` provided, that will override this value _for that post_.
  - `:layout` - string - Elixir module providing page layout for posts. Default is nil

  ### Example

  ```elixir
  config :tableau, Tableau.PostExtension,
    enabled: true,
    dir: "_articles",
    future: true,
    permalink: "/articles/:year/:month/:day/:title",
    layout: "MyApp.PostLayout"
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

  use Tableau.Extension, key: :posts, priority: 100

  import Schematic

  alias Tableau.Extension.Common

  @type post :: %{
          body: String.t(),
          file: String.t(),
          renderer: fun(),
          layout: module(),
          date: DateTime.t()
        }

  @impl Tableau.Extension
  def config(config) do
    unify(
      map(%{
        optional(:enabled) => bool(),
        optional(:dir, "_posts") => oneof([list(str()), str()]),
        optional(:future, false) => bool(),
        optional(:permalink) => str(),
        optional(:layout) => oneof([atom(), str()])
      }),
      config
    )
  end

  @impl Tableau.Extension
  def pre_build(token) do
    %{extensions: %{posts: %{config: config}}} = token

    posts =
      config.dir
      |> List.wrap()
      |> Enum.flat_map(fn path ->
        path
        |> Path.join("**/*.*")
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
          Tableau.Converter.convert(body, converter: assigns.page[:converter], ext: ext)
        end)
      end)
      |> Enum.sort_by(fn post -> post.date end, {:desc, DateTime})
      |> then(fn posts ->
        if config.future do
          posts
        else
          Enum.reject(posts, fn post -> DateTime.after?(post.date, DateTime.utc_now()) end)
        end
      end)

    {:ok, Map.put(token, :posts, posts)}
  end

  @impl Tableau.Extension
  def pre_render(token) do
    graph =
      Tableau.Graph.insert(
        token.graph,
        Enum.map(token.posts, fn post ->
          %Tableau.Page{
            parent: post.layout,
            permalink: post.permalink,
            template: post.renderer,
            opts: post
          }
        end)
      )

    {:ok, Map.put(token, :graph, graph)}
  end

  defp build(filename, front_matter, body, posts_config, renderer) do
    Application.put_env(:date_time_parser, :include_zones_from, ~N[2010-01-01T00:00:00])

    converter =
      case front_matter[:converter] do
        nil -> nil
        converter -> Module.concat([converter])
      end

    front_matter
    |> Map.put(:__tableau_post_extension__, true)
    |> Map.put(:body, body)
    |> Map.put(:title, front_matter[:title] || filename |> Path.basename() |> Path.rootname())
    |> Map.put(:file, filename)
    |> Map.put(:renderer, renderer)
    |> Map.put(:layout, Module.concat([front_matter[:layout] || posts_config.layout]))
    |> Map.put(:converter, converter)
    |> Map.put(
      :date,
      parse_datetime!(front_matter[:date], filename)
    )
    |> Common.build_permalink(posts_config)
  end

  defp parse_datetime!(nil, filename) do
    raise "Missing required front matter missing from post #{filename}: date"
  end

  defp parse_datetime!(datetime, _filename) do
    DateTimeParser.parse_datetime!(datetime,
      assume_time: true,
      assume_utc: true
    )
  end
end
