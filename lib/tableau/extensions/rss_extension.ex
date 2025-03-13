defmodule Tableau.RSSExtension do
  @moduledoc """
  Generate one or more RSS feeds.

  ## Configuration

  Configuration is a keyword list of configuration lists with the key being the name of the XML file to be generated.

  - `:enabled` - boolean - Extension is active or not.
  - `:title` - string (required) - Title of your feed.
  - `:description` - string (required) - Description of your feed.
  - `:language` - string - Language to use in the `<language>` tag. Defaults to "en-us".
  - `:include` - keyword list - List of front matter keys and values to include in the feed. If a post has any value in the list, it'll be included. Defaults to all posts.

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
      feed: [
        enabled: true,
        language: "pt-BR",
        title: "My Elixir Devlog",
        description: "My Journey on Becoming the Best Elixirist",
        include: [tags: ["elixir", "erlang"]] # includes any posts that include one of these tags
      ],
      til: [
        enabled: true,
        language: "en-US",
        title: "Today I Learned",
        description: "Short log of what I learn every day",
        include: [category: ["til"]]
      ]
    ]
  ```
  """
  use Tableau.Extension, key: :rss, type: :post_write, priority: 200

  import Schematic

  @impl Tableau.Extension
  def config(config) do
    unify(
      map(%{
        optional(:enabled, true) => bool(),
        optional(:feeds) => list(feed_s())
      }),
      config
    )
  end

  defp feed_s do
    tuple([
      atom(),
      keyword(%{
        optional(:enabled, true) => bool(),
        optional(:language, "en-us") => str(),
        optional(:include) => include_s(),
        title: str(),
        description: str()
      })
    ])
  end

  defp keyword(options) do
    list(oneof(options))
  end

  defp include_s do
    list(tuple([atom(), list()]))
  end

  @doc """
  The default filter function that is used when including the `:include` option in a feeds configuration.
  """
  def filter(post, include_filter) do
    Enum.any?(include_filter, fn {front_matter_key, values_to_accept} ->
      Enum.any?(post[front_matter_key], fn front_matter_key -> front_matter_key in values_to_accept end)
    end)
  end

  @impl Tableau.Extension
  def run(%{site: %{config: %{url: url, out_dir: out_dir}}, posts: posts, extensions: %{rss: %{config: feeds}}} = token) do
    feeds =
      if is_list(feeds) do
        feeds
      else
        [feed: feeds]
      end

    for {name, feed} <- feeds, feed[:enabled] do
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

      # html
      items =
        for post <- posts, feed[:include] == nil or filter(post, feed[:include]), into: "" do
          """
              <item>
                 <title>#{HtmlEntities.encode(post.title)}</title>
                 <link>#{URI.merge(url, post.permalink)}</link>
                 <pubDate>#{Calendar.strftime(post.date, "%a, %d %b %Y %X %Z")}</pubDate>
                 <guid>#{URI.merge(url, post.permalink)}</guid>
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
end
