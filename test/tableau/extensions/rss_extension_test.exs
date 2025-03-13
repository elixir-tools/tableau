defmodule Tableau.RSSExtensionTest do
  use ExUnit.Case, async: true

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

    test "creates multiple feeds", %{tmp_dir: tmp_dir} do
      posts = [
        post(1, tags: ["post"]),
        post(2, tags: ["til"]),
        post(3, tags: ["recipe"])
      ]

      rss_config = [
        super: %{
          enabled: true,
          language: "en-US",
          title: "The feed to rule them all",
          description: "this is a super feed which comprises all the other feeds"
        },
        feed: %{
          enabled: true,
          language: "en-US",
          title: "My Elixir Devlog",
          description: "My Journey on Becoming the Best Elixirist",
          include: [tags: ["post"]]
        },
        til: %{
          enabled: true,
          language: "en-US",
          title: "Today I Learned",
          description: "Short log of what I learn everyday",
          include: [tags: ["til"]]
        }
      ]

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

      til_path = Path.join(tmp_dir, "til.xml")
      assert File.exists?(til_path)
      til_content = File.read!(til_path)

      assert til_content =~ "Post 2"
      refute til_content =~ "Post 1"
      refute til_content =~ "Post 3"

      super_path = Path.join(tmp_dir, "super.xml")
      assert File.exists?(super_path)
      super_content = File.read!(super_path)

      assert super_content =~ "Post 1"
      assert super_content =~ "Post 2"
      assert super_content =~ "Post 3"
    end
  end

  defp post(idx, overrides) do
    base = %{
      title: "Post #{idx}",
      permalink: "/posts/post-#{1}",
      date: DateTime.utc_now(),
      body: """
      ## Welcome to Post #{idx}

      Here, we post like crazy.
      """
    }

    Map.merge(base, Map.new(overrides))
  end
end
