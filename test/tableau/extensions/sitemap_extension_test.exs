defmodule Tableau.SitemapExtensionTest do
  use ExUnit.Case, async: true

  alias Tableau.SitemapExtension

  @tag :tmp_dir
  test "use _site as default out dir", %{tmp_dir: tmp_dir} do
    token = %{
      site: %{
        config: %{
          url: "http://example.com",
          out_dir: tmp_dir
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

    SitemapExtension.post_write(token)

    sitemap = File.read!("#{tmp_dir}/sitemap.xml")

    assert sitemap ===
             """
             <?xml version="1.0" encoding="UTF-8"?>\
             <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">\
             <url>\
             <lastmod>2018-02-28T00:00:00Z</lastmod>\
             <loc>http://example.com/about</loc>\
             </url>\
             </urlset>\
             """
  end

  @tag :tmp_dir
  test "generates sitemap with optional tags", %{tmp_dir: tmp_dir} do
    token = %{
      site: %{
        config: %{
          out_dir: tmp_dir,
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

    SitemapExtension.post_write(token)

    sitemap = File.read!("#{tmp_dir}/sitemap.xml")

    assert sitemap ===
             """
             <?xml version="1.0" encoding="UTF-8"?>\
             <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">\
             <url>\
             <priority>0.5</priority>\
             <changefreq>monthly</changefreq>\
             <loc>http://example.com/about</loc>\
             </url>\
             </urlset>\
             """
  end
end
