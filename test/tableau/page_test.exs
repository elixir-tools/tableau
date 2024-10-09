defmodule Tableau.PageTest.AboutPage do
  @moduledoc false
  use Tableau.Page,
    layout: Tableau.GraphTest.InnerLayout,
    permalink: "/about"

  def template(_), do: ""
end

defmodule Tableau.PageTest.InnerLayout do
  @moduledoc false
  use Tableau.Layout

  def template(_), do: ""
end

defmodule Tableau.PageTest do
  use ExUnit.Case, async: true

  import Tableau.TestHelpers

  alias Tableau.PageTest.AboutPage

  setup do
    purge_on_exit([
      Tableau.PageTest.AboutPage,
      Tableau.PageTest.InnerLayout
    ])
  end

  test "dsl" do
    assert :page == AboutPage.__tableau_type__()
    assert Tableau.GraphTest.InnerLayout == AboutPage.__tableau_parent__()
    assert "/about" == AboutPage.__tableau_permalink__()
  end
end
