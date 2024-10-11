defmodule Tableau.PostExtensionTest do
  use ExUnit.Case, async: true

  alias Tableau.PostExtension

  @moduletag :tmp_dir

  describe "config" do
    test "provides defaults for dir and future fields" do
      assert {:ok, %{dir: "_posts", future: false}} = PostExtension.config(%{})
    end
  end

  describe "run" do
    setup %{tmp_dir: dir} do
      assert {:ok, config} = PostExtension.config(%{dir: dir, enabled: true, layout: Blog.DefaultPostLayout})

      token = %{
        site: %{config: %{converters: [md: Tableau.MDExConverter]}},
        extensions: %{posts: %{config: config}},
        graph: Graph.new()
      }

      [token: token]
    end

    test "inserts posts into the graph and the token", %{token: token, tmp_dir: dir} do
      File.write(Path.join(dir, "my-post.md"), """
      ---
      layout: Blog.PostLayout
      title: A Bing Bong Blog Post
      date: 2017-02-28
      categories: post
      permalink: /post/2017/02/28/bing-bong/
      ---

      ## Bing

      Bong!
      """)

      File.write(Path.join(dir, "my-second-post.md"), """
      ---
      layout: Blog.PostLayout
      title: My Second Post
      date: 2024-02-28
      categories: post
      permalink: /post/2024/02/28/second-post/
      ---

      ## Now we're cooking

      with gas!
      """)

      File.write(Path.join(dir, "my-future-post.md"), """
      ---
      layout: Blog.PostLayout
      title: My Future Post
      date: 3000-02-28
      categories: post
      permalink: /post/3000/02/28/second-post/
      ---

      Do cars fly yet?
      """)

      assert {:ok, token} = PostExtension.run(token)

      assert %{
               posts: [
                 %{
                   date: ~U[2024-02-28 00:00:00Z],
                   file: ^dir <> "/my-second-post.md",
                   title: "My Second Post",
                   body: "\n## Now we're cooking\n\nwith gas!\n",
                   layout: Blog.PostLayout,
                   __tableau_post_extension__: true,
                   permalink: "/post/2024/02/28/second-post/",
                   categories: "post"
                 } = post_2,
                 %{
                   date: ~U[2017-02-28 00:00:00Z],
                   file: ^dir <> "/my-post.md",
                   title: "A Bing Bong Blog Post",
                   body: "\n## Bing\n\nBong!\n",
                   layout: Blog.PostLayout,
                   __tableau_post_extension__: true,
                   permalink: "/post/2017/02/28/bing-bong/",
                   categories: "post"
                 } = post_1
               ],
               graph: graph
             } = token

      vertices = Graph.vertices(graph)

      assert Enum.any?(vertices, fn v -> is_struct(v, Tableau.Page) and v.permalink == post_1.permalink end)
      assert Enum.any?(vertices, fn v -> is_struct(v, Tableau.Page) and v.permalink == post_2.permalink end)
      assert Enum.any?(vertices, fn v -> v == Blog.PostLayout end)
    end

    test "future: true will render future posts", %{tmp_dir: dir, token: token} do
      File.write(Path.join(dir, "my-future-post.md"), """
      ---
      layout: Blog.PostLayout
      title: My Future Post
      date: 3000-02-28
      categories: post
      permalink: /post/3000/02/28/second-post/
      ---

      Do cars fly yet?
      """)

      assert {:ok, config} = PostExtension.config(%{dir: dir, enabled: true, future: true})

      token = put_in(token.extensions.posts.config, config)

      assert {:ok, token} = PostExtension.run(token)

      assert %{
               posts: [
                 %{
                   date: ~U[3000-02-28 00:00:00Z],
                   file: ^dir <> "/my-future-post.md",
                   title: "My Future Post",
                   body: "\nDo cars fly yet?\n",
                   layout: Blog.PostLayout,
                   __tableau_post_extension__: true,
                   permalink: "/post/3000/02/28/second-post/",
                   categories: "post"
                 } = post
               ],
               graph: graph
             } = token

      vertices = Graph.vertices(graph)

      assert Enum.any?(vertices, fn v -> is_struct(v, Tableau.Page) and v.permalink == post.permalink end)
      assert Enum.any?(vertices, fn v -> v == Blog.PostLayout end)
    end

    test "configured permalink works when you dont specify one", %{tmp_dir: dir, token: token} do
      File.write(Path.join(dir, "my-future-post.md"), """
      ---
      layout: Blog.PostLayout
      title: A Great Post
      date: 2018-02-28
      ---

      A great post
      """)

      assert {:ok, config} = PostExtension.config(%{dir: dir, enabled: true, permalink: "/post/:title"})

      token = put_in(token.extensions.posts.config, config)

      assert {:ok, token} = PostExtension.run(token)

      assert %{
               posts: [
                 %{
                   date: ~U[2018-02-28 00:00:00Z],
                   file: ^dir <> "/my-future-post.md",
                   title: "A Great Post",
                   body: "\nA great post\n",
                   layout: Blog.PostLayout,
                   __tableau_post_extension__: true,
                   permalink: "/post/a-great-post"
                 }
               ]
             } = token
    end

    test "generates permalink from file path if not configured or in front matter", %{tmp_dir: dir, token: token} do
      fancy_dir = Path.join(dir, "/some/fancy/path")
      File.mkdir_p!(fancy_dir)

      File.write(Path.join(fancy_dir, "a-deeply-nested-post.md"), """
      ---
      layout: Blog.PostLayout
      title: A Deeply Nested Post
      date: 2018-02-28
      ---

      A great post
      """)

      assert {:ok, token} = PostExtension.run(token)

      assert %{
               posts: [
                 %{
                   __tableau_post_extension__: true,
                   body: "\nA great post\n",
                   date: ~U[2018-02-28 00:00:00Z],
                   file: ^dir <> "/some/fancy/path/a-deeply-nested-post.md",
                   layout: Blog.PostLayout,
                   permalink: "/some/fancy/path/a-deeply-nested-post",
                   title: "A Deeply Nested Post"
                 }
               ]
             } = token
    end

    test "handles fancy characters in permalink", %{tmp_dir: dir, token: token} do
      File.write(Path.join(dir, "a-post.md"), """
      ---
      layout: Blog.PostLayout
      title: ¿Qué es la programación funcional?
      date: 2018-02-28
      permalink: /:title
      ---

      A great post
      """)

      assert {:ok, token} = PostExtension.run(token)

      assert %{
               posts: [
                 %{
                   __tableau_post_extension__: true,
                   body: "\nA great post\n",
                   date: ~U[2018-02-28 00:00:00Z],
                   file: ^dir <> "/a-post.md",
                   layout: Blog.PostLayout,
                   permalink: "/%C2qu%C3-es-la-programaci%C3n-funcional",
                   title: "¿Qué es la programación funcional?"
                 }
               ]
             } = token
    end

    test "inherits layout from post extension config", %{tmp_dir: dir, token: token} do
      File.write(Path.join(dir, "a-post.md"), """
      ---
      title: Missing layout key
      date: 2018-02-28
      permalink: /:title
      ---

      A great post
      """)

      assert {:ok, token} = PostExtension.run(token)

      assert %{
               posts: [
                 %{
                   __tableau_post_extension__: true,
                   body: "\nA great post\n",
                   date: ~U[2018-02-28 00:00:00Z],
                   file: ^dir <> "/a-post.md",
                   layout: Blog.DefaultPostLayout,
                   permalink: "/missing-layout-key",
                   title: "Missing layout key"
                 }
               ]
             } = token
    end

    test "handles frontmatter data in the permalink", %{tmp_dir: dir, token: token} do
      File.write(Path.join(dir, "a-post.md"), """
      ---
      title: foo man chu_foo.js
      type: articles
      layout: Some.Layout
      date: 2023-02-01 00:01:00
      permalink: /:type/:year/:month/:day/:title
      ---

      A great post
      """)

      assert {:ok, token} = PostExtension.run(token)

      assert %{
               posts: [
                 %{
                   __tableau_post_extension__: true,
                   body: "\nA great post\n",
                   date: ~U[2023-02-01 00:01:00Z],
                   file: ^dir <> "/a-post.md",
                   layout: Some.Layout,
                   permalink: "/articles/2023/02/01/foo-man-chu-foo.js",
                   title: "foo man chu_foo.js",
                   type: "articles"
                 }
               ]
             } = token
    end
  end
end
