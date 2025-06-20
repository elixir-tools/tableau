defmodule Tableau.TagExtension do
  @moduledoc ~S'''
  Creates pages for tags found in posts created by the `Tableau.PostExtension`.

  The `:tags` key provided on every page in the assigns is described by `t:tags/0`.

  The `@page` assign passed to the `layout` provided in the configuration is described by `t:page/0`.

  ## Configuration

  - `:enabled` - boolean - Extension is active or not.
  * `:layout` - module - The `Tableau.Layout` implementation to use.
  * `:permalink` - string - The permalink prefix to use for the tag page, will be joined with the tag name.


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

  @type page :: %{
          title: String.t(),
          tag: String.t(),
          permalink: String.t(),
          posts: [Tableau.PostExtension.post()]
        }

  @type tag :: %{
          title: String.t(),
          tag: String.t(),
          permalink: String.t()
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

    tags =
      for post <- posts, tag <- post |> Map.get(:tags, []) |> Enum.uniq(), reduce: Map.new() do
        acc ->
          permalink = Path.join(permalink, tag)

          tag = %{title: tag, permalink: permalink, tag: tag}
          Map.update(acc, tag, [post], &[post | &1])
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
