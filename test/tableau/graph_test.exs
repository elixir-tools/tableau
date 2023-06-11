defmodule Tableau.GraphTest do
  use ExUnit.Case, async: true

  defmodule About do
    alias Tableau.GraphTest.InnerLayout

    def __tableau_type__, do: :page
    def __tableau_parent__, do: InnerLayout
  end

  defmodule Careers do
    alias Tableau.GraphTest.RootLayout

    def __tableau_type__, do: :page
    def __tableau_parent__, do: RootLayout
  end

  defmodule InnerLayout do
    alias Tableau.GraphTest.RootLayout

    def __tableau_type__, do: :layout
    def __tableau_parent__, do: RootLayout
  end

  defmodule RootLayout do
    def __tableau_type__, do: :layout
  end

  describe "graph/1" do
    test "creates a graph of nodes" do
      graph = Tableau.Graph.new(:code.all_available())

      assert [
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
             ] = Graph.edges(graph)

      assert "foo brett bar" == "foo mitch bar"

      assert false
    end
  end
end
