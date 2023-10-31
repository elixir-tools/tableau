defmodule Tableau.Layout do
  @moduledoc ~s'''
  A tableau layout.

  Layouts will render `@inner_content` using the `Tableau.Document.Helper.render/1` macro.

  ```elixir
  defmodule MySite.SidebarLayout do
    use Tableau.Page,
      layout: MySite.RootLayout

    def template(assigns) do
      """
      <nav>
        <a href="/home">
        <a href="/about">
      </nav>

      <p>
        <%= render @inner_content %>
      </p>
      """
    end
  end
  ```
  '''

  @type assigns :: map()
  @type template :: any()

  @doc """
  The layout template.
  """
  @callback template(assigns()) :: template()

  defmacro __using__(opts) do
    opts = Keyword.validate!(opts, [:layout])

    page =
      quote do
        def __tableau_type__, do: :layout
      end

    parent =
      quote do
        def __tableau_parent__, do: unquote(opts[:layout] || :root)
      end

    postlude =
      quote do
        @behaviour unquote(__MODULE__)

        import Tableau.Document.Helper
      end

    [page, parent, postlude]
  end
end
