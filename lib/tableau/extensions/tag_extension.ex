defmodule Tableau.TagExtension do
  @moduledoc ~S'''
  Creates pages for tags found in posts created by the `Tableau.PostExtension`.

  The `:tags` key provided on every page in the assigns is described by `t:tags/0`.

  The `@page` assign passed to the `layout` provided in the configuration is described by `t:page/0`.

  Unless a tag has a `slug` defined in the plugin `tags` map, tag names will be converted to slugs using `Slug.slugify/2` with options provided in Tableau configuration. These slugs will be used to build the permalink.

  ## Configuration

  - `:enabled` - boolean - Extension is active or not.
  * `:layout` - module - The `Tableau.Layout` implementation to use.
  * `:permalink` - string - The permalink prefix to use for the tag page, will be joined with the tag name.
  * `:tags` - map - A map of tag display values to slug options. Supported options:
    * `:slug` - string - The slug to use for the displayed tag


  ### Configuring Manual Tag Slugs

  ```elixir
  config :tableau, Tableau.TagExtension,
    enabled: true,
    tags: %{
      "C++" => [slug: "c-plus-plus"]
    }
  ```

  With this configuration, the tag `C++` will be have a permalink slug of `c-plus-plus`,
  `Eixir` will be `elixir`, and `Bun.sh` will be `bun-sh`.


  ## Layout and Page

  To take advantage of tag extension, you'll need to define a layout that will render each "tag page" and a normal `Tableau.Page` that lists all tags on your site.

  ### Layout to render a tag page

  ```elixir
  defmodule MySite.TagLayout do
    use Tableau.Layout, layout: MySite.RootLayout

    def template(assigns) do
      ~H"""
      <div>
        <h1>Tag: #{@page.tag}</h1>

        <ul>
          <li :for={post <- @page.posts}>
            <a href={post.permalink}> {post.title}</a>
          </li>
        </ul>
      </div>
      """
    end
  end
  ```

  ### Page to render all tags

  This example page shows listing all takes, sorting them by the number of posts for each tag.

  ```elixir
  defmodule MySite.TagPage do
    use Tableau.Page,
      layout: MySite.RootLayout,
      permalink: "/tags",
      title: "Tags"


    def template(assigns) do
      sorted_tags = Enum.sort_by(assigns.tags, fn {_, p} -> length(p) end, :desc)
      assigns = Map.put(assigns, :tags, sorted_tags)

      ~H"""
      <div>
        <h1>Tags</h1>

        <ul>
          <li :for={{tag, posts} <- @tags}>
            <a href={tag.permalink}>tag.tag</a>

            <span>- {length(posts)}</span>
          </li>
        </ul>
      </div>
      """
    end
  end
  ```
  '''
  use Tableau.Extension,
    enabled: false,
    key: :tag,
    priority: 200

  import Schematic

  alias Tableau.Extension.Common

  @type page :: %{
          title: String.t(),
          tag: String.t(),
          permalink: String.t(),
          posts: [Tableau.PostExtension.post()]
        }

  @type tag :: %{
          title: String.t(),
          tag: String.t(),
          permalink: String.t(),
          slug: String.t()
        }

  @type tags :: %{
          tag() => [Tableau.PostExtension.post()]
        }

  @impl Tableau.Extension
  def config(config) do
    unify(
      oneof([
        map(%{enabled: false}),
        map(%{
          optional(:tags, %{}) => map(keys: str(), values: keyword(%{slug: str()})),
          enabled: true,
          layout: atom(),
          permalink: str()
        })
      ]),
      config
    )
  end

  @impl Tableau.Extension
  def pre_build(token) do
    posts = token.posts
    permalink = token.extensions.tag.config.permalink
    defs = token.extensions.tag.config.tags

    tags =
      for post <- posts, tag <- post |> Map.get(:tags, []) |> Enum.uniq(), reduce: Map.new() do
        acc ->
          slug = get_in(defs, [tag, :slug]) || Common.slugify(tag, token)
          permalink = Path.join(permalink, slug)

          tag = %{title: tag, permalink: permalink, tag: tag, slug: slug}
          Map.update(acc, slug, %{tag: tag, posts: [post]}, &%{tag: tag, posts: [post | &1.posts]})
      end

    tags =
      for {_slug, %{tag: tag, posts: posts}} <- tags, into: %{} do
        {tag, posts}
      end

    {:ok, Map.put(token, :tags, tags)}
  end

  @impl Tableau.Extension
  def pre_render(token) do
    layout = token.extensions.tag.config.layout

    graph =
      Tableau.Graph.insert(
        token.graph,
        for {tag, posts} <- token.tags do
          posts = Enum.sort_by(posts, & &1.date, {:desc, DateTime})

          opts = Map.put(tag, :posts, posts)

          %Tableau.Page{
            parent: layout,
            permalink: tag.permalink,
            template: fn _ -> "" end,
            opts: opts
          }
        end
      )

    {:ok, Map.put(token, :graph, graph)}
  end
end
