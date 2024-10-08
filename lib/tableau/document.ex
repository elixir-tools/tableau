defmodule Tableau.Document do
  @moduledoc false
  alias Tableau.Graph.Nodable

  defmodule Helper do
    @moduledoc "Helper functions for Tableau documents."
    @doc """
    A macro for rendering nested content within a layout.

    Please see the `Tableau.Layout` docs for more info.
    """
    defmacro render(inner_content) do
      quote do
        case unquote(inner_content) do
          [{module, page_assigns, assigns} | rest] ->
            Nodable.template(module, Map.merge(assigns, %{page: page_assigns, inner_content: rest}))

          [] ->
            nil
        end
      end
    end
  end

  def render(graph, module, assigns, page) do
    [root | mods] =
      case Graph.dijkstra(graph, module, :root) do
        path when is_list(path) ->
          path
          |> Enum.reverse()
          |> tl()

        nil ->
          raise "Failed to find layout path for #{inspect(module)}"
      end

    page_assigns = (Nodable.opts(module) || []) |> Map.new() |> Map.merge(page)
    mods = for mod <- mods, do: {mod, page_assigns, assigns}

    Nodable.template(root, Map.merge(assigns, %{inner_content: mods, page: page_assigns}))
  end
end
