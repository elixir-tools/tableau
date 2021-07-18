defmodule TabDemo.Pages.Season do
  use Tableau.Page

  def permalink, do: "/season"

  render do
    span class: "text-red-500 font-bold" do
      "i'm a super cool and smart!"
    end
  end
end
