defmodule Tableau.RSSExtension do
  @moduledoc """
  Generate one or more RSS feeds.

  ## Configuration

  Configuration is a keyword list of configuration lists with the key being the name of the XML file to be generated.

  - `:enabled` - boolean - Extension is active or not.
  - `:title` - string (required) - Title of your feed.
  - `:description` - string (required) - Description of your feed.
  - `:language` - string - Language to use in the `<language>` tag. Defaults to "en-us".
  - `:include` - keyword list - List of front matter keys and values to include in the feed. If a post has any value in the list, it'll be included. Defaults to including everything.
  - `:exclude` - keyword list - List of front matter keys and values to exclude from the feed. If a post has any value in the list, it'll be included. Defaults to not excluding anything.

  ### Example

  ```elixir
  config :tableau, Tableau.RSSExtension,
    enabled: true,
    feeds: [
      super: [
        enabled: true,
        language: "pt-BR",
        title: "The Super Feed",
        description: "Includes all posts on the site"
      ],
      posts: [
        enabled: true,
        language: "pt-BR",
        title: "My Elixir Devlog",
        description: "My Journey on Becoming the Best Elixirist",
        exclude: [category: "til"] # excludes posts with this category
      ],
      til: [
        enabled: true,
        language: "en-US",
        title: "Today I Learned",
        description: "Short log of what I learn every day",
        include: [category: "til"]
      ]
    ]
  ```
  """
  use Tableau.Extension, key: :rss, type: :post_write, priority: 200

  import Schematic

  @impl Tableau.Extension
  def config(config) do
    unify(
      oneof([
        map(%{enabled: false}),
        feed_s(&map/1),
        map(%{
          enabled: true,
          feeds: keyword(values: feed_s(&keyword/1))
        })
      ]),
      config
    )
  end

  defp feed_s(type) do
    type.(%{
      optional(:enabled, true) => bool(),
      optional(:language, "en-us") => str(),
      optional(:include) => include_s(),
      optional(:exclude) => include_s(),
      title: str(),
      description: str()
    })
  end

  defp include_s do
    keyword(values: list(str()))
  end

  @impl Tableau.Extension
  def run(%{site: %{config: %{url: url, out_dir: out_dir}}, posts: posts, extensions: %{rss: %{config: feeds}}} = token) do
    feeds =
      if Map.has_key?(feeds, :feeds) do
        feeds.feeds
      else
        [feed: feeds]
      end

    for {name, feed} <- feeds, feed[:enabled] do
      feed = Map.new(feed)

      prelude =
        """
        <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
        <channel>
          <atom:link href="#{url}/#{name}.xml" rel="self" type="application/rss+xml" />
          <title>#{HtmlEntities.encode(feed.title)}</title>
          <link>#{url}</link>
          <description>#{HtmlEntities.encode(feed.description)}</description>
          <language>#{feed.language}</language>
          <generator>Tableau v#{version()}</generator>
        """

      items =
        for post <- posts,
            feed[:include] == nil || filter(post, feed[:include]),
            feed[:exclude] == nil || not filter(post, feed[:exclude]),
            into: "" do
          """
              <item>
                 <title>#{HtmlEntities.encode(post.title)}</title>
                 <link>#{URI.merge(url, post.permalink)}</link>
                 <pubDate>#{Calendar.strftime(post.date, "%a, %d %b %Y %X %Z")}</pubDate>
                 <guid>#{URI.merge(url, post.permalink)}</guid>
                 <description><![CDATA[ #{post.renderer.(token)} ]]></description>
              </item>
          """
        end

      # html
      postlude =
        """
          </channel>
        </rss>
        """

      File.mkdir_p!(out_dir)
      File.write!("#{out_dir}/#{name}.xml", prelude <> items <> postlude)
    end

    {:ok, token}
  end

  defp version do
    case :application.get_key(:tableau, :vsn) do
      {:ok, version} -> to_string(version)
      _ -> "dev"
    end
  end

  defp filter(post, include_filter) do
    Enum.any?(include_filter, fn {front_matter_key, values_to_accept} ->
      post[front_matter_key]
      |> List.wrap()
      |> Enum.any?(fn front_matter_key ->
        front_matter_key in List.wrap(values_to_accept)
      end)
    end)
  end
end
