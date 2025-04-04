defmodule Tableau.PostExtension do
  @moduledoc """
  Content files (with YAML frontmatter) in the configured posts directory will be automatically compiled into Tableau pages.

  Certain frontmatter keys are required and all keys are passed as options to the `Tableau.Page`.

  ## Options

  Frontmatter is compiled with `yaml_elixir` and all keys are converted to atoms.

  * `:title` - The title of the post.
  * `:permalink` - The permalink of the post. `:title` will be replaced with the posts title and non alphanumeric characters removed. Optional.
  * `:date` - A string representation of an Elixir `NaiveDateTime`, often presented as a `sigil_N`. This will be converted to your configured timezone.
  * `:layout` - A string representation of a Tableau layout module.
  * `:converter` - A string representation of a converter module. (optional)

  ## Example

  ```yaml
  id: "Update.Volume3"
  title: "The elixir-tools Update Vol. 3"
  permalink: "/news/:title"
  date: "~N[2023-09-19 01:00:00]"
  draft: false
  layout: "ElixirTools.PostLayout"
  converter: "MyConverter"
  ```

  ## Permalink

  The permalink is a string with colon prefixed template variables.

  These variables will be swapped with the corresponding YAML Frontmatter key, with the result being piped through `to_string/1`.

  In addition, there are `:year`, `:month`, and `:day` template variables.

  ## Configuration

  - `:enabled` - boolean - Extension is active or not.
  - `:dir` - string - Directory to scan for markdown files. Defaults to `_posts`
  - `:future` - boolean - Show posts that have dates later than the current timestamp, or time at which the site is generated.
  - `:permalink` - string - Default output path for posts. Accepts `:title` as a replacement keyword, replaced with the post's provided title. If a post has a `:permalink` provided, that will override this value _for that post_.
  - `:layout` - string - Elixir module providing page layout for posts. Default is nil
  - `:draft` - boolean - Only show this post in dev.

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
  # configs/config.exs
  config :tableau, :config,
    converters: [
      md: Tableau.MDExConverter,
      adoc: MySite.AsciiDocConverter
    ],
  ```

  As noted above, a converter can be overridden on a specific page, using the frontmatter `:converter` key.
  """

  use Tableau.Extension, key: :posts, type: :pre_build, priority: 100

  import Schematic

  alias Tableau.Extension.Common

  @type post :: %{
          body: String.t(),
          file: String.t(),
          layout: module(),
          date: DateTime.t()
        }

  @impl Tableau.Extension
  def config(config) do
    unify(
      map(%{
        optional(:enabled) => bool(),
        optional(:dir, "_posts") => str(),
        optional(:drafts, "_drafts") => str(),
        optional(:future, false) => bool(),
        optional(:permalink) => str(),
        optional(:layout) => oneof([atom(), str()])
      }),
      config
    )
  end

  @impl Tableau.Extension
  def run(token) do
    %{site: %{config: %{converters: converters}}, extensions: %{posts: %{config: config}}} = token
    exts = Enum.map_join(converters, ",", fn {ext, _} -> to_string(ext) end)

    posts =
      config.dir
      |> Path.join("**/*.{#{exts}}")
      |> Common.paths()
      |> Common.entries(fn %{path: path, front_matter: front_matter, pre_convert_body: body, ext: ext} ->
        {
          build(path, front_matter, body, config),
          fn assigns ->
            converter =
              case front_matter[:converter] do
                nil -> converters[ext]
                converter -> Module.concat([converter])
              end

            converter.convert(path, front_matter, body, assigns)
          end
        }
      end)
      |> Enum.sort_by(fn {post, _} -> post.date end, {:desc, DateTime})
      |> then(fn posts ->
        if config.future do
          posts
        else
          Enum.reject(posts, fn {post, _} -> DateTime.after?(post.date, DateTime.utc_now()) end)
        end
      end)
      |> then(fn posts ->
        unless config.drafts do
          posts
        else
          Enum.reject(posts, fn {post, _} -> post.file =~ config.drafts end)
        end
      end)
      |> Enum.reject(fn {post, _} -> Map.get(post, :draft, false) == true end)

    graph =
      Tableau.Graph.insert(
        token.graph,
        Enum.map(posts, fn {post, renderer} ->
          %Tableau.Page{parent: post.layout, permalink: post.permalink, template: renderer, opts: post}
        end)
      )

    {:ok,
     token
     |> Map.put(:posts, posts |> Enum.unzip() |> elem(0))
     |> Map.put(:graph, graph)}
  end

  defp build(filename, attrs, body, posts_config) do
    Application.put_env(:date_time_parser, :include_zones_from, ~N[2010-01-01T00:00:00])

    attrs
    |> Map.put(:__tableau_post_extension__, true)
    |> Map.put(:body, body)
    |> Map.put(:file, filename)
    |> Map.put(:layout, Module.concat([attrs[:layout] || posts_config.layout]))
    |> Map.put(:date, DateTimeParser.parse_datetime!(attrs.date, assume_time: true, assume_utc: true))
    |> Common.build_permalink(posts_config)
  end
end
