defmodule Tableau.Page do
  alias Tableau.Store
  alias Tableau.Render

  require Temple.Component

  defstruct module: nil, permalink: nil

  defmacro __using__(_) do
    quote do
      import Temple.Component
      import Tableau.Page, only: [layout: 1]

      def path_info() do
        Tableau.Page.path_from_module(__MODULE__)
      end

      def permalink() do
        "/" <> Enum.join(path_info(), "/")
      end

      def layout?, do: false

      defdelegate layout, to: Tableau.Layout, as: :default

      defoverridable permalink: 0, path_info: 0, layout: 0
    end
  end

  defmacro layout(layout) do
    quote do
      def layout() do
        unquote(layout)
      end
    end
  end

  def build() do
    for {mod, _, _} <- :code.all_available(), tableau_page?(mod), into: %{} do
      mod =
        mod
        |> to_string()
        |> String.to_existing_atom()

      {mod.permalink(), struct(__MODULE__, module: mod, permalink: mod.permalink())}
    end
  end

  def path_from_module(module) do
    parts = module |> Module.split()

    prefix =
      Tableau.module_prefix()
      |> to_string()
      |> String.replace("Elixir.", "")

    for part <- parts, part not in [prefix, "Pages"], do: String.downcase(part)
  end

  defp tableau_page?(mod) do
    String.match?(to_string(mod), ~r/#{Tableau.module_prefix()}\.Pages/)
  end

  defimpl Tableau.Renderable do
    def render(%{module: module, permalink: permalink}) do
      %{posts: posts} = Store.fetch()

      posts = Map.values(posts)

      page =
        module
        |> Render.gather_modules([])
        |> Render.recursively_render(posts: posts)
        |> Phoenix.HTML.safe_to_string()

      dir = "_site#{permalink}"

      File.mkdir_p!(dir)
      File.write!(dir <> "/index.html", page)
    end

    def layout?(%{module: module}) do
      module.layout?
    end
  end
end
