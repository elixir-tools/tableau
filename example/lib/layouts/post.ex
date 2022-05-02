defmodule TabDemo.Layouts.Post do
  use Tableau.Layout

  import Temple

  layout TabDemo.Layouts.App

  def render(assigns) do
    temple do
      h1 class: "text-4xl font-bold", do: @post.frontmatter["title"]

      hr class: "border-2"

      slot :default
    end
  end
end
