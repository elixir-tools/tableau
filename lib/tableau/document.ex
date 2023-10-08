defmodule Tableau.Document do
  @moduledoc false
  defmodule Helper do
    @doc """
    A macro for rendering nested content within a layout.

    Please see the `Tableau.Layout` docs for more info.
    """
    defmacro render(inner_content) do
      quote do
        case unquote(inner_content) do
          [{module, page_assigns, assigns} | rest] ->
            module.template(Map.merge(assigns, %{page: page_assigns, inner_content: rest}))

          [] ->
            nil
        end
      end
    end
  end

  def render(graph, module, assigns) do
    [root | mods] =
      case Graph.dijkstra(graph, module, :root) do
        path when is_list(path) ->
          path
          |> Enum.reverse()
          |> tl()

        nil ->
          raise "Failed to find layout path for #{inspect(module)}"
      end

    page_assigns = Map.new(module.__tableau_opts__() || [])
    mods = for mod <- mods, do: {mod, page_assigns, assigns}

    root.template(Map.merge(assigns, %{inner_content: mods, page: page_assigns}))
  end
end
