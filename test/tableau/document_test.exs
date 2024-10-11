defmodule Tableau.DocumentTest.About do
  @moduledoc false
  
  import Tableau.TestHelpers

  alias Tableau.DocumentTest.InnerLayout

  require EEx

  def __tableau_type__, do: :page
  def __tableau_parent__, do: InnerLayout
  def __tableau_permalink__, do: "/about"
  def __tableau_opts__, do: [yo: "lo"]

  EEx.function_from_string(
    :def,
    :template,
    ~s'''
    <div id="<%= @page.yo %>" class="<%= @page.foo %>">
      hi
    </div>
    ''',
    [:assigns]
  )
end

defmodule Tableau.DocumentTest.Index do
  @moduledoc false
  

  alias Tableau.DocumentTest.InnerLayout

  require EEx

  def __tableau_type__, do: :page
  def __tableau_parent__, do: InnerLayout
  def __tableau_permalink__, do: "/"
  def __tableau_opts__, do: []

  EEx.function_from_string(
    :def,
    :template,
    ~s'''
    <div id="home">
      Home page!
    </div>
    ''',
    [:_assigns]
  )
end

defmodule Tableau.DocumentTest.InnerLayout do
  @moduledoc false
  import Tableau.Document.Helper, only: [render: 1]
  

  alias Tableau.DocumentTest.RootLayout

  require EEx

  def __tableau_type__, do: :layout
  def __tableau_parent__, do: RootLayout

  EEx.function_from_string(
    :def,
    :template,
    ~s'''
    <div id="inner-layout">
      <%= render(@inner_content) %>
    </div>
    ''',
    [:assigns]
  )
end

defmodule Tableau.DocumentTest.RootLayout do
  @moduledoc false
  import Tableau.Document.Helper, only: [render: 1]
  

  require EEx

  def __tableau_type__, do: :layout

  EEx.function_from_string(
    :def,
    :template,
    ~s'''
    <html>
      <head></head>
      <body>
        <%= render @inner_content %>
      </body>
    </html>
    ''',
    [:assigns]
  )
end

defmodule Tableau.DocumentTest do
  use ExUnit.Case, async: true

  import Tableau.TestHelpers

  alias Tableau.Document

  setup do
    mods = [
      Tableau.DocumentTest.About,
      Tableau.DocumentTest.Index,
      Tableau.DocumentTest.InnerLayout,
      Tableau.DocumentTest.RootLayout
    ]

    purge_on_exit(mods)

    [mods: mods]
  end

  test "renders a document", %{mods: mods} do
    graph = Graph.new()

    graph = Tableau.Graph.insert(graph, mods)
    content = Document.render(graph, __MODULE__.About, %{site: %{}}, %{foo: "bar"})

    assert Floki.parse_document!(content) ===
             [
               {"html", [],
                [
                  {"head", [], []},
                  {"body", [],
                   [
                     {"div", [{"id", "inner-layout"}], [{"div", [{"id", "lo"}, {"class", "bar"}], ["\n  hi\n"]}]}
                   ]}
                ]}
             ]
  end
end
