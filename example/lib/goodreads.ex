# defmodule TabDemo.Goodreads do
#   defstruct [:data]

#   defimpl Tableau.Provider do
#     def fetch(goodreads) do
#       Application.ensure_all_started(:req)

#       response =
#         Req.get!(
#           "https://www.goodreads.com/review/list.xml",
#           params: [
#             v: 2,
#             id: System.get_env("GOODREADS_ID"),
#             shelf: "read",
#             key: System.get_env("GOODREADS_KEY"),
#             per_page: 200
#           ]
#         ).body
#         |> EasyXML.parse!()

#       data =
#         for review <- EasyXML.xpath(response, "//review") do
#           book = EasyXML.xpath(review, "//book") |> List.first()

#           %{
#             id: book["id"],
#             title: book["title_without_series"],
#             asin: book["asin"],
#             image: book["image_url"],
#             author: List.first(EasyXML.xpath(book, "//author"))["name"],
#             date_read: review["read_at"]
#           }
#         end

#       %{goodreads | data: data}
#     end
#   end
# end
