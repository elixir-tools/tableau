defmodule TabDemo.Pages.Bookshelf do
  use Tableau.Page

  import Temple

  def render(assigns) do
    temple do
      ul do
        for book <- @books do
          li do
            "#{book.title} by #{book.author} on #{book.date_read}"
          end
        end
      end
    end
  end
end
