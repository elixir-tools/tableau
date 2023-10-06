defmodule Tableau.DocumentTest.About do
  import Tableau.Strung
  require EEx
  alias Tableau.DocumentTest.InnerLayout

  def __tableau_type__, do: :page
  def __tableau_parent__, do: InnerLayout
  def __tableau_permalink__, do: "/about"
  def __tableau_extra__, do: [yo: "lo"]

  EEx.function_from_string(
    :def,
    :template,
    ~g'''
    <div id="<%= @yo %>">
      hi
    </div>
    '''html,
    [:assigns]
  )
end

defmodule Tableau.DocumentTest.Index do
  import Tableau.Strung
  require EEx
  alias Tableau.DocumentTest.InnerLayout

  def __tableau_type__, do: :page
  def __tableau_parent__, do: InnerLayout
  def __tableau_permalink__, do: "/"
  def __tableau_extra__, do: []

  EEx.function_from_string(
    :def,
    :template,
    ~g'''
    <div id="home">
      Home page!
    </div>
    '''html,
    [:_assigns]
  )
end

defmodule Tableau.DocumentTest.InnerLayout do
  import Tableau.Strung
  import Tableau.Document.Helper, only: [render: 1]
  require EEx
  alias Tableau.DocumentTest.RootLayout

  def __tableau_type__, do: :layout
  def __tableau_parent__, do: RootLayout

  EEx.function_from_string(
    :def,
    :template,
    ~g'''
    <div id="inner-layout">
      <%= render(@inner_content) %>
    </div>
    '''html,
    [:assigns]
  )
end

defmodule Tableau.DocumentTest.RootLayout do
  import Tableau.Strung
  import Tableau.Document.Helper, only: [render: 1]
  require EEx
  def __tableau_type__, do: :layout

  EEx.function_from_string(
    :def,
    :template,
    ~g'''
    <html>
      <head></head>
      <body>
        <%= render @inner_content %>
      </body>
    </html>
    '''html,
    [:assigns]
  )
end

defmodule Tableau.DocumentTest do
  use ExUnit.Case, async: true

  alias Tableau.Document

  test "renders a document" do
    graph = Tableau.Graph.new(:code.all_available())
    content = Document.render(graph, __MODULE__.About, %{site: %{}})

    assert Floki.parse_document!(content) ===
             [
               {"html", [],
                [
                  {"head", [], []},
                  {"body", [],
                   [
                     {"div", [{"id", "inner-layout"}], [{"div", [{"id", "lo"}], ["\n  hi\n"]}]}
                   ]}
                ]}
             ]
  end
end
