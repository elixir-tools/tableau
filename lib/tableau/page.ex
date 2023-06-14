defmodule Tableau.Page do
  @moduledoc ~s'''
  A tableau page.

  A page is a basic unit of a static site.

  ```elixir
  defmodule MySite.HomePage do
    use Tableau.Page,
      layout: MySite.RootLayout,
      permalink: "/"

    def template(assigns) do
      """
      <h1>My Site</h1>

      <p>
        Welcome to my site!
      </p>
      """
    end
  end
  ```
  '''

  @type assigns :: map()
  @type template :: any()

  @doc """
  The page template.
  """
  @callback template(assigns()) :: template()

  defmacro __using__(opts) do
    opts = Keyword.validate!(opts, [:layout, :permalink])

    page =
      quote do
        def __tableau_type__, do: :page
      end

    parent =
      quote do
        def __tableau_parent__, do: unquote(opts[:layout])
      end

    permalink =
      quote do
        def __tableau_permalink__, do: unquote(opts[:permalink])
      end

    postlude =
      quote do
        @behaviour unquote(__MODULE__)
      end

    [page, parent, permalink, postlude]
  end
end
