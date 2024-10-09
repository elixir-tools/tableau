defmodule Tableau.Graph do
  @moduledoc false
  alias Tableau.Graph.Nodable

  def insert(graph, nodes) do
    for node <- nodes, Nodable.type(node) != :error, reduce: graph do
      graph ->
        {:ok, parent} = Nodable.parent(node)
        Graph.add_edge(graph, node, parent)
    end
  end
end
