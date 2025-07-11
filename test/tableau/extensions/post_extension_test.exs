defmodule Tableau.PostExtensionTest.Layout do
  @moduledoc false
  use Tableau.Layout

  require EEx

  EEx.function_from_string(
    :def,
    :template,
    ~s'''
    <div>
      <%= render(@inner_content) %>
    </div>
    ''',
    [:assigns]
  )
end

defmodule Tableau.PostExtensionTest do
  use ExUnit.Case, async: true

  import Tableau.Support.Helpers

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

      assert {:ok, token} = PostExtension.pre_build(token)
      assert {:ok, token} = PostExtension.pre_render(token)

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

      assert Enum.any?(vertices, &page_with_permalink?(&1, post_1.permalink))
      assert Enum.any?(vertices, &page_with_permalink?(&1, post_2.permalink))

      assert Blog.PostLayout in vertices
    end

    test "can read posts from multiple directories", %{tmp_dir: dir, token: token} do
      posts_dir = Path.join(dir, "_posts")

      File.mkdir_p(posts_dir)

      File.write(Path.join(posts_dir, "my-post-in-posts-dir.md"), """
      ---
      layout: Blog.PostLayout
      title: My Dir Post
      date: 2017-02-01
      categories: post
      permalink: /post/2017/02/01/normal-post/
      ---

      I am a real boy.
      """)

      drafts_dir = Path.join(dir, "_drafts")
      File.mkdir_p(drafts_dir)

      File.write(Path.join(drafts_dir, "my-post-in-drafts-dir.md"), """
      ---
      layout: Blog.PostLayout
      title: My Draft Dir Post
      date: 2017-03-01
      categories: post
      permalink: /post/2017/03/01/drafts-dir-post/
      ---

      The answer is not 42.
      """)

      assert {:ok, config} = PostExtension.config(%{dir: [posts_dir, drafts_dir], enabled: true})

      token = put_in(token.extensions.posts.config, config)

      assert {:ok, token} = PostExtension.pre_build(token)
      assert {:ok, token} = PostExtension.pre_render(token)

      assert %{
               posts: [
                 %{
                   date: ~U[2017-03-01 00:00:00Z],
                   file: ^drafts_dir <> "/my-post-in-drafts-dir.md",
                   title: "My Draft Dir Post",
                   body: "\nThe answer is not 42.\n",
                   layout: Blog.PostLayout,
                   __tableau_post_extension__: true,
                   permalink: "/post/2017/03/01/drafts-dir-post/",
                   categories: "post"
                 } = post1,
                 %{
                   date: ~U[2017-02-01 00:00:00Z],
                   file: ^posts_dir <> "/my-post-in-posts-dir.md",
                   title: "My Dir Post",
                   body: "\nI am a real boy.\n",
                   layout: Blog.PostLayout,
                   __tableau_post_extension__: true,
                   permalink: "/post/2017/02/01/normal-post/",
                   categories: "post"
                 } = post2
               ],
               graph: graph
             } = token

      vertices = Graph.vertices(graph)

      assert Enum.any?(vertices, &page_with_permalink?(&1, post1.permalink))
      assert Enum.any?(vertices, &page_with_permalink?(&1, post2.permalink))
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

      assert {:ok, token} = PostExtension.pre_build(token)
      assert {:ok, token} = PostExtension.pre_render(token)

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

      assert Enum.any?(vertices, &page_with_permalink?(&1, post.permalink))

      assert Blog.PostLayout in vertices
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

      assert {:ok, token} = PostExtension.pre_build(token)
      assert {:ok, token} = PostExtension.pre_render(token)

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
      assert {:ok, config} = PostExtension.config(%{dir: [dir], enabled: true})

      token = put_in(token.extensions.posts.config, config)
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

      assert {:ok, token} = PostExtension.pre_build(token)
      assert {:ok, token} = PostExtension.pre_render(token)

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

      assert {:ok, token} = PostExtension.pre_build(token)
      assert {:ok, token} = PostExtension.pre_render(token)

      assert %{
               posts: [
                 %{
                   __tableau_post_extension__: true,
                   body: "\nA great post\n",
                   date: ~U[2018-02-28 00:00:00Z],
                   file: ^dir <> "/a-post.md",
                   layout: Blog.PostLayout,
                   permalink: "/que-es-la-programacion-funcional",
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

      assert {:ok, token} = PostExtension.pre_build(token)
      assert {:ok, token} = PostExtension.pre_render(token)

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

      assert {:ok, token} = PostExtension.pre_build(token)
      assert {:ok, token} = PostExtension.pre_render(token)

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

    test "renders with a custom converter in frontmatter", %{tmp_dir: dir, token: token} do
      File.write(Path.join(dir, "a-post.md"), """
      ---
      title: foo man chu_foo.js
      type: articles
      layout: Tableau.PostExtensionTest.Layout
      date: 2023-02-01 00:01:00
      permalink: /:type/:year/:month/:day/:title
      converter: Tableau.PostExtensionTest
      ---

      A great post
      """)

      assert {:ok, token} = PostExtension.pre_build(token)
      assert {:ok, token} = PostExtension.pre_render(token)

      assert %{posts: [%{converter: "Tableau.PostExtensionTest"}], graph: graph} = token

      page =
        graph
        |> Graph.vertices()
        |> Enum.find(fn p ->
          case p do
            %Tableau.Page{permalink: "/articles/2023/02/01/foo-man-chu-foo.js"} -> true
            _ -> false
          end
        end)

      graph = Tableau.Graph.insert(graph, [Tableau.PostExtensionTest.Layout])

      content = Tableau.Document.render(graph, page, %{}, %{})

      assert content =~ "A GREAT POST"
    end
  end

  def convert(_, _, body, _), do: String.upcase(body)
end
