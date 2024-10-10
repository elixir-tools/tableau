defmodule Tableau.SitemapExtension do
  @moduledoc """
  Generate a sitemap.xml for your site, for improved search-engine indexing.

  ## Configuration

  - `:enabled` - boolean - Extension is active or not.

  ### Example

  ```elixir
  config :tableau, Tableau.SitemapExtension,
    enabled: true,
  ```

  ## Custom attributes

  Any page may add attributes to its sitemap `<url>` entry by adding a `sitemap` entry, with a map of elements to add

  ### Frontmatter

  ```yaml
  title: "Some Page"
  sitemap:
    priority: 0.8
    changefreq: hourly
  ```

  ### Tableau.Page

  ```elixir
  defmodule MySite.AboutPage do
    use Tableau.Page,
      layout: MySite.RootLayout,
      permalink: "/about",
      sitemap: %{priority: 0.8, changefreq: "monthly"}

    # ...
  end
  ```

  Generated sitemap is stored in the root of your site, at /sitemap.xml.

  For more information about sitemaps, see <https://www.sitemaps.org>.
  """

  use Tableau.Extension, key: :sitemap, type: :post_write, priority: 300

  require Logger

  def run(%{site: %{config: %{url: root}, pages: pages}} = token) do
    urls =
      for page <- pages, uniq: true do
        loc =
          [{:loc, nil, URI.merge(root, page.permalink)}]
          |> prepend_lastmod(page)
          |> prepend_sitemap_assigns(page)

        {:url, nil, loc}
      end

    xml =
      XmlBuilder.document(
        :urlset,
        [
          xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9",
          "xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
          "xsi:schemaLocation":
            "http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"
        ],
        urls
      )

    File.mkdir_p!("_site")
    File.write!("_site/sitemap.xml", XmlBuilder.generate_iodata(xml))

    {:ok, token}
  rescue
    e ->
      Logger.error(Exception.format(:error, e, __STACKTRACE__))
      {:error, :fail}
  end

  defp prepend_lastmod(body, %{date: date}) do
    [{:lastmod, nil, DateTime.to_iso8601(date)} | body]
  end

  defp prepend_lastmod(body, _), do: body

  defp prepend_sitemap_assigns(body, %{sitemap: sitemap_data}) do
    for {key, value} <- sitemap_data, reduce: body do
      acc -> [{key, [], value} | acc]
    end
  end

  defp prepend_sitemap_assigns(body, _), do: body
end
