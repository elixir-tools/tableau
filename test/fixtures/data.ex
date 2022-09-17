defmodule MyData do
  use Tableau.Data,
    books1: "test/support/fixtures/books.yml",
    books2: "test/support/fixtures/books.json",
    books3: "test/support/fixtures/books.toml",
    books4: %Tableau.Support.MyData.Http{}
end
