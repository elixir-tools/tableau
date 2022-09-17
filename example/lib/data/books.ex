defmodule TabDemo.Data.Books do
  use Tableau.Data

  data :books do
    Application.ensure_all_started(:req)

    response =
      Req.get!("https://www.goodreads.com/review/list.xml",
        params: [
          v: 2,
          id: "69703261-mitchell",
          shelf: "read",
          key: System.get_env("GOODREADS_KEY"),
          per_page: 200
        ]
      ).body
      |> EasyXML.parse!()

    for review <- EasyXML.xpath(response, "//review") do
      book = EasyXML.xpath(review, "//book") |> List.first()

      %{
        id: book["id"],
        title: book["title_without_series"],
        asin: book["asin"],
        image: book["image_url"],
        author: List.first(EasyXML.xpath(book, "//author"))["name"],
        date_read: review["read_at"]
      }
    end
  end
end
