defmodule Tableau.Graph do
  @moduledoc false
  alias Tableau.Graph.Node

  def new(modules) do
    graph = Graph.new()

    for {mod, _, _} <- modules,
        mod = Module.concat([to_string(mod)]),
        Node.type(mod) != :error,
        reduce: graph do
      graph ->
        case Node.type(mod) do
          {:ok, :pages} ->
            for page <- mod.pages(), reduce: graph do
              graph ->
                Graph.add_edge(graph, page, page.parent)
            end

          _ ->
            {:ok, parent} = Node.parent(mod)
            Graph.add_edge(graph, mod, parent)
        end
    end
  end
end
