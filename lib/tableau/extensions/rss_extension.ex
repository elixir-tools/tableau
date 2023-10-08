defmodule Tableau.RSSExtension.Config do
  import Schematic

  defstruct [:title, :description, language: "en-us", enabled: true]

  def new(input), do: unify(schematic(), input)

  def schematic do
    schema(
      __MODULE__,
      %{
        optional(:enabled) => bool(),
        optional(:language) => str(),
        title: str(),
        description: str()
      },
      convert: false
    )
  end
end

defmodule Tableau.RSSExtension do
  use Tableau.Extension, key: :rss, type: :post_write, priority: 200

  def run(%{site: %{config: %{url: url}}, posts: posts, rss: rss} = token) do
    prelude =
      """
      <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
      <channel>
        <atom:link href="#{url}/feed.xml" rel="self" type="application/rss+xml" />
        <title>#{rss.title}</title>
        <link>#{url}</link>
        <description>#{rss.description}</description>
        <language>#{rss.language}</language>
        <generator>Tableau v#{version()}</generator>
      """

    # html
    items =
      for post <- posts, into: "" do
        """
            <item>
               <title>#{post.title}</title>
               <link>https://#{Path.join(url, post.permalink)}</link>
               <pubDate>#{Calendar.strftime(post.date, "%a, %d %b %Y %X %Z")}</pubDate>
               <guid>http://#{Path.join(url, post.permalink)}</guid>
               <description><![CDATA[ #{post.body} ]]></description>
            </item>
        """
      end

    # html
    postlude =
      """
        </channel>
      </rss>
      """

    File.mkdir_p!("_site")
    File.write!("_site/feed.xml", prelude <> items <> postlude)

    {:ok, token}
  end

  defp version() do
    case :application.get_key(:tableau, :vsn) do
      {:ok, version} -> to_string(version)
      _ -> "dev"
    end
  end
end
