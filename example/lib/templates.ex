defmodule TabDemo.About do
  import Strung
  require EEx
  alias TabDemo.InnerLayout

  def __tableau_type__, do: :page
  def __tableau_parent__, do: InnerLayout
  def __tableau_permalink__, do: "/about"

  EEx.function_from_string(
    :def,
    :template,
    ~g'''
    <div class="<%= @class %>">
      hi, my name is motch
    </div>
    '''html,
    [:assigns]
  )
end

defmodule TabDemo.Index do
  import Strung
  require EEx
  alias TabDemo.InnerLayout

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

defmodule TabDemo.InnerLayout do
  import Strung
  import Tableau.Document.Helper, only: [render: 2]
  require EEx
  alias TabDemo.RootLayout

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

defmodule TabDemo.RootLayout do
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

