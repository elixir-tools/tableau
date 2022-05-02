defmodule TabDemo.Pages.Posts do
  use Tableau.Page

  import Temple
  import TabDemo.Components

  def render(assigns) do
    temple do
      ul class: "list-disc pl-6" do
        for post <- @posts do
          c &li/1 do
            a class: "text-blue-500 hover:underline font-bold", href: post.permalink do
              post.frontmatter["title"] <> " 🧨"
            end
          end
        end
      end
    end
  end
end
