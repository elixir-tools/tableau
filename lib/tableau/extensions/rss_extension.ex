defmodule Tableau.RSSExtension do
  @moduledoc """
  YAML files and Elixir scripts (.exs) in the confgiured directory will be automatically parsed/executed and made available in an `@data` assign in your templates.

  Elixir scripts will be executed and the last expression returned as the data.

  ## Configuration

  - `:enabled` - boolean - Extension is active or not.
  - `:title` - string (required) - Title of your feed.
  - `:description` - string (required) - Description of your feed.
  - `:language` - string - Langauge to use in the `<language>` tag. Defaults to "en-us"

  ### Example

  ```elixir
  config :tableau, Tableau.RSSExtension,
    enabled: true,
    language: "pt-BR",
    title: "My Elixir Devlog",
    description: "My Journey on Becoming the Best Elixirist"
  ```
  """
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

  defp version do
    case :application.get_key(:tableau, :vsn) do
      {:ok, version} -> to_string(version)
      _ -> "dev"
    end
  end
end
