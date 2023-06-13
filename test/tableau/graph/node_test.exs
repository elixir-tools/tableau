defmodule Tableau.Graph.NodeTest do
  use ExUnit.Case, async: true

  alias Tableau.Graph.Node

  defmodule About do
    alias Tableau.Graph.NodeTest.Layout

    def __tableau_type__, do: :page
    def __tableau_parent__, do: Layout
    def __tableau_permalink__, do: "/about"

    def template(_) do
      ""
    end
  end

  defmodule Layout do
    def __tableau_type__, do: :layout

    def template(_) do
      ""
    end
  end

  defmodule Math do
  end

  describe "type/1" do
    test "returns the node type" do
      assert {:ok, :page} == Node.type(About)
      assert {:ok, :layout} == Node.type(Layout)
    end

    test "returns :error for non node" do
      assert :error == Node.type(Math)
    end
  end

  describe "parent/1" do
    test "returns the parent module" do
      assert {:ok, Layout} == Node.parent(About)
      assert {:ok, :root} == Node.parent(Layout)
    end

    test "returns error when module is not a node" do
      assert :error == Node.parent(Math)
    end
  end
end
