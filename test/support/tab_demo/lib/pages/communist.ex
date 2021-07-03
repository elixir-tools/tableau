defmodule TabDemo.Pages.Communist do
  use Tableau.Page

  layout TabDemo.Layouts.WithHeader

  render do
    span class: "text-red-500 font-bold" do
      "i'm a super cool and smart!"
    end
  end
end
