defmodule TabDemo.Pages.About do
  use Tableau.Page
  import Temple

  def render(_) do
    temple do
      span class: "text-red-500 font-bold" do
        "i'm a super cool and smart!"

        div class: "font-bold italic text-green-800" do
          "and i'm very green"
        end
      end
    end
  end
end
