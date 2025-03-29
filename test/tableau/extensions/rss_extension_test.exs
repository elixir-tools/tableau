defmodule Tableau.RSSExtensionTest do
  use ExUnit.Case, async: true

  import Tableau.Support.Helpers

  alias Tableau.RSSExtension

  describe "run/1" do
    @describetag :tmp_dir
    # NOTE: this is deprecated, but we want backwards compatibility for a while
    test "creates a single feed", %{tmp_dir: tmp_dir} do
      posts = [
        post(1, tags: ["post"]),
        post(2, tags: ["til"]),
        post(3, tags: ["recipe"])
      ]

      rss_config = %{
        enabled: true,
        language: "pt-BR",
        title: "My Elixir Devlog",
        description: "My Journey on Becoming the Best Elixirist",
        include: [tags: ["post"]]
      }

      token = %{
        site: %{
          config: %{
            out_dir: tmp_dir,
            url: "https://example.com"
          }
        },
        posts: posts,
        extensions: %{
          rss: %{config: rss_config}
        }
      }

      assert {:ok, _} = RSSExtension.run(token)

      feed_path = Path.join(tmp_dir, "feed.xml")
      assert File.exists?(feed_path)
      feed_content = File.read!(feed_path)

      assert feed_content =~ "Post 1"
      refute feed_content =~ "Post 2"
      refute feed_content =~ "Post 3"
    end
  end

  describe "multiple feeds" do
    @describetag :tmp_dir
    setup %{tmp_dir: tmp_dir} do
      posts = [
        post(1, tags: ["post"]),
        post(2, tags: ["til"], category: "important"),
        post(3, tags: ["recipe"], category: "casual")
      ]

      rss_config = %{
        enabled: true,
        feeds: [
          super: %{
            enabled: true,
            language: "en-US",
            title: "The feed to rule them all",
            description: "this is a super feed which comprises all the other feeds"
          },
          til: %{
            enabled: true,
            language: "en-US",
            title: "Today I Learned",
            description: "Short log of what I learn everyday",
            include: [tags: ["til"]]
          }
        ]
      }

      token = %{
        site: %{
          config: %{
            out_dir: tmp_dir,
            url: "https://example.com"
          }
        },
        posts: posts,
        extensions: %{
          rss: %{config: rss_config}
        }
      }

      [token: token]
    end

    test "include works with various frontmatter", %{token: token, tmp_dir: tmp_dir} do
      token =
        put_in(token.extensions.rss.config.feeds,
          feed: %{
            enabled: true,
            language: "en-US",
            title: "My Elixir Devlog",
            description: "My Journey on Becoming the Best Elixirist",
            include: [tags: ["post"]]
          },
          casual: %{
            enabled: true,
            language: "en-US",
            title: "Casual posts",
            description: "",
            include: [category: "casual"]
          }
        )

      assert {:ok, _} = RSSExtension.run(token)

      # only contains posts tagged as "post"
      feed_path = Path.join(tmp_dir, "feed.xml")
      assert File.exists?(feed_path)
      feed_content = File.read!(feed_path)

      assert feed_content =~ "Post 1"
      refute feed_content =~ "Post 2"
      refute feed_content =~ "Post 3"
      # only contains posts with category as "casual"
      casual_path = Path.join(tmp_dir, "casual.xml")
      assert File.exists?(casual_path)
      casual_content = File.read!(casual_path)

      refute casual_content =~ "Post 2"
      refute casual_content =~ "Post 1"
      assert casual_content =~ "Post 3"
    end

    test "includes everything if there is no includes key", %{token: token, tmp_dir: tmp_dir} do
      token =
        put_in(token.extensions.rss.config.feeds,
          feed: %{
            enabled: true,
            language: "en-US",
            title: "My Elixir Devlog",
            description: "My Journey on Becoming the Best Elixirist"
          }
        )

      assert {:ok, _} = RSSExtension.run(token)

      # contains all posts
      feed_path = Path.join(tmp_dir, "feed.xml")
      assert File.exists?(feed_path)
      feed_content = File.read!(feed_path)

      assert feed_content =~ "Post 1"
      assert feed_content =~ "Post 2"
      assert feed_content =~ "Post 3"
    end

    test "excludes various frontmatter", %{token: token, tmp_dir: tmp_dir} do
      token =
        put_in(token.extensions.rss.config.feeds,
          not_posts: %{
            enabled: true,
            language: "en-US",
            title: "",
            description: "",
            exclude: [tags: ["post"]]
          },
          not_casual: %{
            enabled: true,
            language: "en-US",
            title: "",
            description: "",
            exclude: [category: "casual"]
          }
        )

      assert {:ok, _} = RSSExtension.run(token)

      # only contains posts not tagged as "post"
      not_posts_path = Path.join(tmp_dir, "not_posts.xml")
      assert File.exists?(not_posts_path)
      not_posts_content = File.read!(not_posts_path)

      refute not_posts_content =~ "Post 1"
      assert not_posts_content =~ "Post 2"
      assert not_posts_content =~ "Post 3"

      # only contains posts without category as "bar"
      not_casual_path = Path.join(tmp_dir, "not_casual.xml")
      assert File.exists?(not_casual_path)
      not_casual_content = File.read!(not_casual_path)

      assert not_casual_content =~ "Post 2"
      assert not_casual_content =~ "Post 1"
      refute not_casual_content =~ "Post 3"
    end
  end
end
