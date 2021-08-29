defmodule TabDemo.Layouts.Post do
  use Tableau.Layout

  layout(TabDemo.Layouts.App)

  render do
    h1 class: "text-4xl font-bold", do: @post.frontmatter["title"]

    hr class: "border border-2"

    slot :default
  end
end
