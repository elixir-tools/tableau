defmodule TabDemo.Pages.Constitutional do
  use Tableau.Page

  render do
    span class: "text-red-500 font-bold" do
      "The constitution is very odd"
    end
  end
end
