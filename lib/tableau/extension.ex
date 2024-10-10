defmodule Tableau.Extension do
  @moduledoc ~s'''
  A tableau extension.

  An extension can be used to generate other kinds of content.

  ## Options

  * `:key` - The key in which the extensions configuration and data is loaded.
  * `:type` - The type of extension. See below for a description.
  * `:priority` - An integer used for ordering extensions of the same type.
  * `:enabled` - Whether or not to enable the extension. Defaults to true, and can be configured differently based on the extension.

  ## Types

  There are currently the following extension types:

  - `:pre_build` - executed before tableau builds your site and writes anything to disk.
  - `:pre_write` - executed after tableau builds your site but before it writes anything to disk.
  - `:post_write` - executed after tableau builds your site and writes everything to disk.

  ## The Graph

  Tableau pages and layouts form a DAG, a Directed Acyclic Graph, and this graph is used to build each page when writing to disk.

  Your extension can create data to insert into the site token and can also inserted pages into the graph to be written to disk when the time comes.

  ## Example

  In this example, we create a simple post extension that reads markdown files from disk, inserts them into the graph, and inserts them into the token.

  By inserting them into the token, you are able to access them inside your templates, for example, a posts listing page.

  ```elixir
  defmodule MySite.PostsExtension do
    use Tableau.Extension, key: :posts, type: :pre_build, priority: 300

    def run(token) do
      posts = 
        for post <- Path.wildcard("_posts/**/*.md") do
          %Tableau.Page{
            parent: MySite.RootLayout,
            permalink: Path.join("posts", Path.rootname(post)),
            template: Markdown.render(post),
            opts: %{}
          }
        end

      graph = Tableau.Graph.insert(token.graph, posts)

      {:ok,
       token
       |> Map.put(:posts, posts)
       |> Map.put(:graph, graph)}
    end
  end
  ```
  '''

  @typep extension_type :: :pre_build | :post_write
  @type token :: map()

  @doc """
  The extension entry point.

  The function is passed a token and can return a new token with new data loaded into it.
  """
  @callback run(token()) :: {:ok, token()} | :error

  defmacro __using__(opts) do
    opts = Keyword.validate!(opts, [:key, :enabled, :type, :priority])

    prelude =
      quote do
        def __tableau_extension_type__, do: unquote(opts)[:type]
        def __tableau_extension_key__, do: unquote(opts)[:key]
        def __tableau_extension_enabled__, do: unquote(opts)[:enabled] || true
        def __tableau_extension_priority__, do: unquote(opts)[:priority] || 0
      end

    postlude =
      quote do
        @behaviour unquote(__MODULE__)
      end

    [prelude, postlude]
  end

  @doc false
  @spec type(module()) :: extension_type()
  def type(module) do
    if function_exported?(module, :__tableau_extension_type__, 0) do
      {:ok, module.__tableau_extension_type__()}
    else
      :error
    end
  end

  @doc false
  @spec key(module()) :: extension_type()
  def key(module) do
    if function_exported?(module, :__tableau_extension_key__, 0) do
      {:ok, module.__tableau_extension_key__()}
    else
      :error
    end
  end

  @doc false
  @spec enabled?(module()) :: boolean()
  def enabled?(module) do
    if function_exported?(module, :__tableau_extension_enabled__, 0) do
      module.__tableau_extension_enabled__()
    else
      false
    end
  end
end
