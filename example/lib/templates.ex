defmodule TabDemo.About do
  use Tableau.Page, layout: TabDemo.InnerLayout, permalink: "/about"
  use TabDemo.Component

  def template(assigns) do
    temple do
      div @attrs do
        "hi, my name is motch"
      end
    end
  end
end

defmodule TabDemo.Index do
  use Tableau.Page, layout: TabDemo.InnerLayout, permalink: "/"
  use TabDemo.Component

  def template(_assigns) do
    temple do
      div id: "home", class: "text-red-500" do
        "Home page! whoa i changed!"
      end
    end
  end
end

defmodule TabDemo.InnerLayout do
  use Tableau.Layout, layout: TabDemo.RootLayout
  use TabDemo.Component

  import Tableau.Document.Helper, only: [render: 2]

  def template(assigns) do
    temple do
      div id: "inner-layout", class: "border border-red-500" do
        span(do: "haha")
        render(@inner_content, attrs: [class: "text-blue-500"])
      end
    end
  end
end

defmodule TabDemo.RootLayout do
  use Tableau.Layout
  use TabDemo.Component

  import Tableau.Document.Helper, only: [render: 1]

  def template(assigns) do
    temple do
      html do
        head do
          link(href: "/css/site.css", rel: "stylesheet")
        end

        body do
          render(@inner_content)

          c(&Tableau.Components.live_reload/1)
        end
      end
    end
  end
end
