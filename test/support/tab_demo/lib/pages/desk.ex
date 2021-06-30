defmodule TabDemo.Pages.Desk do
  import Temple.Component

  render do
    span class: "text-red-500 font-bold" do
      span do
        "I'm a desk"
      end
    end
  end
end
