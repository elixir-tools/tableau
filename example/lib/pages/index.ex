defmodule TabDemo.Pages.Index do
  use Tableau.Page

  def permalink(), do: "/"

  render do
    "Hello, world!!"
  end
end
