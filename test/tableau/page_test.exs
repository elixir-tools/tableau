defmodule Tableau.PageTest.AboutPage do
  use Tableau.Page,
    layout: Tableau.GraphTest.InnerLayout,
    permalink: "/about"

  def template(_), do: ""
end

defmodule Tableau.PageTest do
  use ExUnit.Case, async: true

  alias Tableau.PageTest.AboutPage

  test "dsl" do
    assert :page == AboutPage.__tableau_type__()
    assert Tableau.GraphTest.InnerLayout == AboutPage.__tableau_parent__()
    assert "/about" == AboutPage.__tableau_permalink__()
  end
end
