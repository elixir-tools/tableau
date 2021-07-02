defmodule TabDemo.Pages.Licence do
  use Tableau.Page

  render do
    span class: "text-red-500 font-bold" do
      "i'm a super cool and smart!"
    end
  end
end
