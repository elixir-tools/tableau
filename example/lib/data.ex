defmodule TabDemo.Data do
  use Tableau.Data,
    books: %TabDemo.Goodreads{}
end
