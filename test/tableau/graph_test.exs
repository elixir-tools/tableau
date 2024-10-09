defmodule Tableau.GraphTest do
  use ExUnit.Case, async: true

  import Tableau.TestHelpers

  defmodule About do
    @moduledoc false
    alias Tableau.GraphTest.InnerLayout

    def __tableau_type__, do: :page
    def __tableau_parent__, do: InnerLayout
    def __tableau_permalink__, do: "/about"
    def __tableau_opts__, do: []

    def template(_), do: ""
  end

  defmodule Careers do
    @moduledoc false
    alias Tableau.GraphTest.RootLayout

    def __tableau_type__, do: :page
    def __tableau_parent__, do: RootLayout
    def __tableau_permalink__, do: "/about"
    def __tableau_opts__, do: []
    def template(_), do: ""
  end

  defmodule InnerLayout do
    @moduledoc false
    alias Tableau.GraphTest.RootLayout

    def __tableau_type__, do: :layout
    def __tableau_parent__, do: RootLayout
    def template(_), do: ""
  end

  defmodule RootLayout do
    @moduledoc false
    def __tableau_type__, do: :layout

    def template(_), do: ""
  end

  describe "graph/1" do
    setup do
      mods = [
        Tableau.GraphTest.About,
        Tableau.GraphTest.Careers,
        Tableau.GraphTest.InnerLayout,
        Tableau.GraphTest.RootLayout
      ]

      purge_on_exit(mods)

      [mods: mods]
    end

    test "creates a graph of nodes", %{mods: mods} do
      graph = Tableau.Graph.insert(Graph.new(), mods)
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
