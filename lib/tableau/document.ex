defmodule Tableau.Document do
  @moduledoc false
  defmodule Helper do
    @doc """
    A macro for rendering nested content within a layout.

    Please see the `Tableau.Layout` docs for more info.
    """
    defmacro render(inner_content, extra_assigns \\ Macro.escape(%{})) do
      quote do
        case unquote(inner_content) do
          [module | rest] ->
            module.template(
              Map.merge(Map.new(unquote(extra_assigns)), %{
                site: Access.fetch!(var!(assigns), :site),
                inner_content: rest
              })
            )

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

    root.template(Map.merge(assigns, %{inner_content: mods}))
  end
end
