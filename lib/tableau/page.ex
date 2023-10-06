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
    opts = Keyword.validate!(opts, [:layout, :permalink, extra: []])

    quote do
      @behaviour unquote(__MODULE__)

      def __tableau_type__, do: :page
      def __tableau_parent__, do: unquote(opts[:layout])
      def __tableau_permalink__, do: unquote(opts[:permalink])
      def __tableau_extra__, do: unquote(opts[:extra])
    end
  end
end
