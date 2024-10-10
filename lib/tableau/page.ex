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
  The page struct allows you to create pages as data structures and manually insert them into the Graph.
  """
  defstruct [:parent, :permalink, :template, :opts]

  defimpl Tableau.Graph.Nodable do
    def template(nodable, assigns) do
      nodable.template.(assigns)
    end

    def type(_nodable), do: {:ok, :page}
    def parent(nodable), do: {:ok, nodable.parent}
    def opts(nodable), do: nodable.opts
    def permalink(nodable), do: nodable.permalink
  end

  @doc """
  The page template.
  """
  @callback template(assigns()) :: template()

  defmacro __using__(opts) do
    layout = Keyword.fetch!(opts, :layout)
    permalink = Keyword.fetch!(opts, :permalink)

    quote do
      @behaviour unquote(__MODULE__)

      def __tableau_type__, do: :page
      def __tableau_parent__, do: unquote(layout)
      def __tableau_permalink__, do: unquote(permalink)
      def __tableau_opts__, do: unquote(opts)
    end
  end
end
