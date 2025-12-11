defmodule Tableau.TagExtensionTest do
  use ExUnit.Case, async: true

  import Tableau.Support.Helpers

  alias Tableau.TagExtension
  alias Tableau.TagExtensionTest.Layout

  describe "config" do
    test "handles tag slugs correctly" do
      config =
        %{
          enabled: true,
          layout: Layout,
          permalink: "/tags",
          tags: %{"C++" => [slug: "c-plus-plus"]}
        }

      assert {:ok, ^config} = TagExtension.config(config)
    end
  end

  describe "run" do
    test "creates tag pages and tags key" do
      posts = [
        # dedups tags
        post(1, tags: ["post", "post"]),
        # post can have multiple tags, includes posts from same tag
        # tags will be converted to slugs for linking
        post(2, tags: ["til", "post", "Today I Learned", "C++"]),
        post(3, tags: ["recipe"])
      ]

      token = %{
        posts: posts,
        graph: Graph.new(),
        extensions: %{tag: %{config: %{layout: Layout, permalink: "/tags", tags: %{"C++" => [slug: "c-plus-plus"]}}}}
      }

      assert {:ok, token} = TagExtension.pre_build(token)
      assert {:ok, token} = TagExtension.pre_render(token)

      assert %{
               tags: %{
                 %{tag: "post", title: "post", permalink: "/tags/post", slug: "post"} => [
                   %{title: "Post 2"},
                   %{title: "Post 1"}
                 ],
                 %{tag: "recipe", title: "recipe", permalink: "/tags/recipe", slug: "recipe"} => [%{title: "Post 3"}],
                 %{tag: "til", title: "til", permalink: "/tags/til", slug: "til"} => [%{title: "Post 2"}],
                 %{
                   tag: "Today I Learned",
                   title: "Today I Learned",
                   permalink: "/tags/today-i-learned",
                   slug: "today-i-learned"
                 } => [
                   %{title: "Post 2"}
                 ],
                 %{tag: "C++", title: "C++", permalink: "/tags/c-plus-plus", slug: "c-plus-plus"} => [%{title: "Post 2"}]
               },
               graph: graph
             } = token

      vertices = Graph.vertices(graph)

      assert Enum.any?(vertices, &page_with_permalink?(&1, "/tags/post"))
      assert Enum.any?(vertices, &page_with_permalink?(&1, "/tags/recipe"))
      assert Enum.any?(vertices, &page_with_permalink?(&1, "/tags/til"))
      assert Enum.any?(vertices, &page_with_permalink?(&1, "/tags/today-i-learned"))
      assert Enum.any?(vertices, &page_with_permalink?(&1, "/tags/c-plus-plus"))

      assert Layout in vertices
    end
  end
end
