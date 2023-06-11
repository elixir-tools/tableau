defmodule Mix.Tasks.Tableau.BuildTest.About do
  import Strung
  require EEx
  alias Mix.Tasks.Tableau.BuildTest.InnerLayout

  def __tableau_type__, do: :page
  def __tableau_parent__, do: InnerLayout
  def __tableau_permalink__, do: "/about"

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

defmodule Mix.Tasks.Tableau.BuildTest.Index do
  import Strung
  require EEx
  alias Mix.Tasks.Tableau.BuildTest.InnerLayout

  def __tableau_type__, do: :page
  def __tableau_parent__, do: InnerLayout
  def __tableau_permalink__, do: "/"

  EEx.function_from_string(
    :def,
    :template,
    ~g'''
    <div id="home">
      Home page!
    </div>
    '''html,
    [:assigns]
  )
end

defmodule Mix.Tasks.Tableau.BuildTest.InnerLayout do
  import Strung
  import Tableau.Document.Helper, only: [render: 2]
  require EEx
  alias Mix.Tasks.Tableau.BuildTest.RootLayout

  def __tableau_type__, do: :layout
  def __tableau_parent__, do: RootLayout

  EEx.function_from_string(
    :def,
    :template,
    ~g'''
    <div id="inner-layout">
      <%= render(@inner_content, class: "text-red") %>
    </div>
    '''html,
    [:assigns]
  )
end

defmodule Mix.Tasks.Tableau.BuildTest.RootLayout do
  import Strung
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

defmodule Mix.Tasks.Tableau.BuildTest do
  use ExUnit.Case, async: true

  alias Mix.Tasks.Tableau.Build

  @tag :tmp_dir
  test "renders all pages", %{tmp_dir: out} do
    documents = Build.run(["--out", out])

    assert 2 == length(documents)

    assert File.exists?(Path.join(out, "/index.html"))
    assert File.exists?(Path.join(out, "/about/index.html"))
  end
end
