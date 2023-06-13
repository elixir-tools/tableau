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
        {:ok, parent} = Node.parent(mod)
        Graph.add_edge(graph, mod, parent)
    end
  end
end
