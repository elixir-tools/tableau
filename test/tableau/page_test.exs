defmodule Tableau.PageTest.AboutPage do
  use Tableau.Page,
    layout: InnerLayout,
    permalink: "/about"

  import Strung
  require EEx

  EEx.function_from_string(
    :def,
    :template,
    ~g'''
    <div class="<%= @class %>">
      hi
    </div>
    '''html,
    [:assigns]
  )
end

defmodule Tableau.PageTest do
  use ExUnit.Case, async: true

  alias Tableau.PageTest.AboutPage

  test "dsl" do
    assert :page == AboutPage.__tableau_type__()
    assert InnerLayout  == AboutPage.__tableau_parent__()
    assert "/about" == AboutPage.__tableau_permalink__()
  end
end
