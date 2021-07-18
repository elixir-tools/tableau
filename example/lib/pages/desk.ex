defmodule TabDemo.Pages.Desk do
  use Tableau.Page

  layout(TabDemo.Layouts.WithHeader)

  render do
    span class: "text-red-500 font-bold" do
      span do
        "I'm a desk"
      end
    end
  end
end
