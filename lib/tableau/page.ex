defmodule Tableau.Page do
  alias Tableau.Store

  defstruct module: nil, permalink: nil

  defmacro __using__(_) do
    quote do
      import Temple.Component

      def path_info() do
        Tableau.Page.path_from_module(__MODULE__)
      end

      def permalink() do
        "/" <> Enum.join(path_info(), "/")
      end

      def layout?, do: false

      defoverridable permalink: 0, path_info: 0
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

      layout = Module.concat(Tableau.module_prefix(), App)

      posts = Map.values(posts)

      page =
        Phoenix.View.render_layout layout, :self, posts: posts do
          Phoenix.View.render(module, :self, posts: posts)
        end
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
