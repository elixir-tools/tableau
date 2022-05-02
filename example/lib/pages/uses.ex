defmodule TabDemo.Pages.Uses do
  use Tableau.Page

  import Temple

  def render(_) do
    temple do
      h2 class: "font-bold text-3xl", do: "Uses"

      ul do
        li do
          "computers"
        end

        li do
          "tennis"
        end

        li do
          "wood"
        end
      end
    end
  end
end
