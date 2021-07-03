defmodule TabDemo.Pages.About do
  use Tableau.Page

  render do
    span class: "text-red-500 font-bold" do
      "i'm a super cool and smart! dfkj"

      div class: "font-bold italic" do
        "and i'm very humble"
      end
    end
  end
end
