defmodule TabDemo.Pages.Posts do
  import Temple.Component

  render do
    ul class: "list-disc pl-6" do
      for post <- @posts do
        li do
          a class: "text-blue-500 hover:underline", href: post.permalink do
            post["title"]
          end
        end
      end
    end
  end
end
