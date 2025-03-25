defmodule Tableau.SitemapExtensionTest do
  use ExUnit.Case, async: true

  alias Tableau.SitemapExtension

  test "use _site as default out dir" do
    token = %{
      site: %{
        config: %{
          url: "http://example.com"
        },
        pages: [
          %{
            date: ~U[2018-02-28 00:00:00Z],
            permalink: "/about",
            title: "About"
          }
        ]
      }
    }

    SitemapExtension.run(token)

    sitemap = File.read!("_site/sitemap.xml")

    assert Floki.parse_document!(sitemap) === [
             {:pi, "xml", [{"version", "1.0"}, {"encoding", "UTF-8"}]},
             {"urlset",
              [
                {"xmlns", "http://www.sitemaps.org/schemas/sitemap/0.9"},
                {"xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance"},
                {"xsi:schemalocation",
                 "http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"}
              ],
              [
                {"url", [],
                 [
                   {"lastmod", [], ["2018-02-28T00:00:00Z"]},
                   {"loc", [], ["http://example.com/about"]}
                 ]}
              ]}
           ]
  end

  @tag :tmp_dir
  test "generates sitemap with optional tags", %{tmp_dir: tmp_dir} do
    token = %{
      out: tmp_dir,
      site: %{
        config: %{
          url: "http://example.com"
        },
        pages: [
          %{
            permalink: "/about",
            title: "About",
            sitemap: %{
              priority: 0.5,
              changefreq: "monthly"
            }
          }
        ]
      }
    }

    SitemapExtension.run(token)

    sitemap = File.read!("#{tmp_dir}/sitemap.xml")

    assert Floki.parse_document!(sitemap) === [
             {:pi, "xml", [{"version", "1.0"}, {"encoding", "UTF-8"}]},
             {"urlset",
              [
                {"xmlns", "http://www.sitemaps.org/schemas/sitemap/0.9"},
                {"xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance"},
                {"xsi:schemalocation",
                 "http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"}
              ],
              [
                {"url", [],
                 [
                   {"changefreq", [], ["monthly"]},
                   {"priority", [], ["0.5"]},
                   {"loc", [], ["http://example.com/about"]}
                 ]}
              ]}
           ]
  end
end
