defmodule Tableau.SitemapExtension.Config do
  @moduledoc false

  def new(input), do: {:ok, input}
end

defmodule Tableau.SitemapExtension do
  @moduledoc """
  Generate a sitemap.xml for your tableau site, for improved search-engine indexing.

  Any page may add information to its sitemap `<url>` entry by adding a `sitemap` entry, with a map of elements to add

  With frontmatter:
  ```
  ---
  title: "Some Page"
  sitemap:
    priority: 0.8
    changefreq: hourly
  ---
  ```

  In a `Tableau.Page`

  ```
  defmodule MySite.AboutPage do
    use Tableau.Page,
      layout: MySite.RootLayout,
      permalink: "/about",
      sitemap: %{changefreq: "monthly"}

  ```

  Generated sitemap is stored in the root of your site, at /sitemap.xml

  For more information about sitemaps, see <https://www.sitemaps.org>

  """

  use Tableau.Extension, key: :sitemap, type: :post_write, priority: 300

  def run(%{site: %{config: %{url: root}, pages: pages}} = token) do
    for_result =
      for page <- pages, uniq: true do
        [{:loc, nil, URI.merge(root, page.permalink)}]
        |> maybe_add_lastmod(page)
        |> maybe_add_sitemap_assigns(page)
        |> Enum.reverse()
        |> then(&{:url, nil, &1})
      end

    sitemap =
      for_result
      |> then(
        &XmlBuilder.document(
          :urlset,
          [
            xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9",
            "xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
            "xsi:schemaLocation":
              "http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"
          ],
          &1
        )
      )
      |> XmlBuilder.generate_iodata()

    File.mkdir_p!("_site")
    File.write!("_site/sitemap.xml", sitemap)

    {:ok, token}
  end

  defp maybe_add_lastmod(body, %{date: date}) do
    [{:lastmod, nil, DateTime.to_iso8601(date)} | body]
  end

  defp maybe_add_lastmod(body, _), do: body

  defp maybe_add_sitemap_assigns(body, %{sitemap: sitemap_data}) do
    for {key, value} <- sitemap_data, reduce: body do
      acc -> [{key, [], value} | acc]
    end
  end

  defp maybe_add_sitemap_assigns(body, _), do: body
end
