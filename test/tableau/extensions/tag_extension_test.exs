defmodule Tableau.TagExtensionTest do
  use ExUnit.Case, async: true

  import Tableau.Support.Helpers

  alias Tableau.TagExtension
  alias Tableau.TagExtensionTest.Layout

  describe "run" do
    test "creates tag pages and tags key" do
      posts = [
        # dedups tags
        post(1, tags: ["post", "post"]),
        # post can have multiple tags, includes posts from same tag
        post(2, tags: ["til", "post"]),
        post(3, tags: ["recipe"])
      ]

      token = %{
        posts: posts,
        graph: Graph.new(),
        extensions: %{tag: %{config: %{layout: Layout, permalink: "/tags"}}}
      }

      assert {:ok, token} = TagExtension.pre_build(token)
      assert {:ok, token} = TagExtension.pre_render(token)

      assert %{
               tags: %{
                 %{tag: "post", title: "post", permalink: "/tags/post"} => [%{title: "Post 2"}, %{title: "Post 1"}],
                 %{tag: "recipe", title: "recipe", permalink: "/tags/recipe"} => [%{title: "Post 3"}],
                 %{tag: "til", title: "til", permalink: "/tags/til"} => [%{title: "Post 2"}]
               },
               graph: graph
             } = token

      vertices = Graph.vertices(graph)

      assert Enum.any?(vertices, &page_with_permalink?(&1, "/tags/post"))
      assert Enum.any?(vertices, &page_with_permalink?(&1, "/tags/recipe"))
      assert Enum.any?(vertices, &page_with_permalink?(&1, "/tags/til"))

      assert Layout in vertices
    end
  end
end
