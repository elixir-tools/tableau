defmodule TabDemo.Pages.Index do
  use Tableau.Page

  import Temple

  permalink("/")

  def render(_) do
    temple do
      div class: "border-[5px] border-cyan-500" do
        ul do
          for book <- TabDemo.Data.data().books.data do
            li do
              span class: "font-bold" do
                book.title
              end
            end
          end
        end

        "Hello, world!! from temple"
      end
    end
  end
end
