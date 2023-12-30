defmodule Tableau.PostExtension.Posts.PostTest do
  use ExUnit.Case, async: true

  alias Tableau.PostExtension.Posts.Post

  describe "build/3" do
    test "substitutes arbitrary front matter into permalink" do
      actual =
        Post.build(
          "some/file/name.md",
          %{
            title: "foo man chu",
            type: "articles",
            permalink: "/blog/:type/:title",
            layout: Some.Layout,
            date: "2023-10-13"
          },
          "hi"
        )

      assert %{permalink: "/blog/articles/foo-man-chu"} = actual
    end

    test "substitutes date pieces into permalink" do
      actual =
        Post.build(
          "some/file/name.md",
          %{
            title: "foo man chu_foo.js",
            type: "articles",
            permalink: "/:year/:month/:day/:title",
            layout: Some.Layout,
            date: "2023-02-01 00:01:00"
          },
          "hi"
        )

      assert %{permalink: "/2023/02/01/foo-man-chu-foo.js"} = actual
    end
  end
end
