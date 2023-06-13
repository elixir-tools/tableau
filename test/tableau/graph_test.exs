defmodule Tableau.GraphTest do
  use ExUnit.Case, async: true

  defmodule About do
    alias Tableau.GraphTest.InnerLayout

    def __tableau_type__, do: :page
    def __tableau_parent__, do: InnerLayout

    def template(_), do: ""
  end

  defmodule Careers do
    alias Tableau.GraphTest.RootLayout

    def __tableau_type__, do: :page
    def __tableau_parent__, do: RootLayout
    def template(_), do: ""
  end

  defmodule InnerLayout do
    alias Tableau.GraphTest.RootLayout

    def __tableau_type__, do: :layout
    def __tableau_parent__, do: RootLayout
    def template(_), do: ""
  end

  defmodule RootLayout do
    def __tableau_type__, do: :layout

    def template(_), do: ""
  end

  describe "graph/1" do
    test "creates a graph of nodes" do
      graph = Tableau.Graph.new(:code.all_available())
      edges = Graph.edges(graph)

      for e <- [
            %Graph.Edge{
              v1: Tableau.GraphTest.InnerLayout,
              v2: Tableau.GraphTest.RootLayout
            },
            %Graph.Edge{
              v1: Tableau.GraphTest.About,
              v2: Tableau.GraphTest.InnerLayout
            },
            %Graph.Edge{
              v1: Tableau.GraphTest.RootLayout,
              v2: :root
            },
            %Graph.Edge{
              v1: Tableau.GraphTest.Careers,
              v2: Tableau.GraphTest.RootLayout
            }
          ] do
        assert e in edges
      end
    end
  end
end
