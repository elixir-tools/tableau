defmodule TabDemo.Pages.Lid do
  use Tableau.Page

  render do
    span class: "text-red-500 font-bold" do
      "boop"
    end
  end
end
