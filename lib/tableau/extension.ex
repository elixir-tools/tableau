defmodule Tableau.Extension do
  @moduledoc ~s'''
  A tableau extension.

  An extension can be used to generate other kinds of content.

  ## Types

  There are currently the following extension types:

  - `:pre_build` - executed before tableau builds your site and writes anything to disk.

  ## Priority

  Extensions can be assigned a numeric priority for used with sorting.

  ```elixir
  defmodule MySite.PostsExtension do
    use Tableau.Extension, type: :pre_build, priority: 300

    def run(_site) do
      posts = Path.wildcard("_posts/**/*.md")

      for post <- post do
        post
        |> Markdown.render()
        |> then(&File.write(Path.join(Path.rootname(post), "index.html"), &1))
      end

      :ok
    end
  end
  ```
  '''

  @typep extension_type :: :pre_build

  @doc """
  The extension entry point.

  The function is passed the a set of default assigns.
  """
  @callback run(map()) :: :ok | :error

  defmacro __using__(opts) do
    opts = Keyword.validate!(opts, [:type, :priority])

    prelude =
      quote do
        def __tableau_extension_type__, do: unquote(opts)[:type]
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
end
