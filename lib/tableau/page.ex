defmodule Tableau.Page do
  alias Tableau.Store
  alias Tableau.Render

  defstruct module: nil, permalink: nil, md5: nil, posts: []

  defmacro __using__(_) do
    quote do
      import Tableau.Page, only: [layout: 1, permalink: 1]

      def path_info() do
        Tableau.Page.path_from_module(__MODULE__)
      end

      def permalink() do
        "/" <> Enum.join(path_info(), "/")
      end

      def layout?, do: false

      def file_path, do: __ENV__.file

      def tableau_page?(), do: true

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

  defmacro permalink(permalink) do
    quote do
      def permalink() do
        unquote(permalink)
      end
    end
  end

  def build(callback \\ fn x -> x end) do
    for {mod, _, _} <- :code.all_available(), tableau_page?(mod) do
      mod =
        mod
        |> to_string()
        |> String.to_existing_atom()

      page = struct(__MODULE__, module: mod, permalink: mod.permalink(), posts: Store.posts())
      callback.(page)
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
    with mod <- Module.concat([to_string(mod)]),
         true <- function_exported?(mod, :tableau_page?, 0) do
      mod.tableau_page?()
    else
      _ ->
        false
    end
  end

  defimpl Tableau.Renderable do
    def render(%{module: module, posts: posts}, _opts \\ []) do
      module
      |> Render.gather_modules([])
      |> Render.recursively_render(posts: posts)
    end

    def write!(%{permalink: permalink}, content) do
      dir = "_site#{permalink}"

      File.mkdir_p!(dir)
      File.write!(dir <> "/index.html", content)

      :ok
    end

    def refresh(page) do
      modules = Render.gather_modules(page.module, [])

      struct!(page, md5: for(mod <- modules, do: mod.__info__(:md5)), posts: Store.posts())
    end

    def layout?(%{module: module}) do
      module.layout?
    end
  end
end
