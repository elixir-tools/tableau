defmodule Tableau.PageExtensionTest do
  use ExUnit.Case, async: true

  alias Tableau.PageExtension

  @moduletag :tmp_dir

  describe "config" do
    test "provides defaults for dir and future fields" do
      assert {:ok, %{dir: "_pages"}} = PageExtension.config(%{})
    end
  end

  describe "run" do
    setup %{tmp_dir: dir} do
      assert {:ok, config} = PageExtension.config(%{dir: dir, enabled: true})

      token = %{
        site: %{config: %{converters: [md: Tableau.MDExConverter]}},
        extensions: %{pages: %{config: config}},
        graph: Graph.new()
      }

      [token: token]
    end

    test "inserts pages into the graph and the token", %{token: token, tmp_dir: dir} do
      File.write(Path.join(dir, "my-page.md"), """
      ---
      layout: Blog.PageLayout
      title: How to Make Stuff
      permalink: /page/2page02/28/bing-bong/
      ---

      ## Bing

      Bong!
      """)

      File.write(Path.join(dir, "my-second-page.md"), """
      ---
      layout: Blog.PageLayout
      title: My Second Page
      date: 2024-02-28
      categories: page
      permalink: /page/2page02/28/second-page/
      ---

      ## Now we're cooking

      with gas!
      """)

      assert {:ok, token} = PageExtension.run(token)

      assert %{
               pages: [
                 %{
                   file: ^dir <> "/my-page.md",
                   title: "How to Make Stuff",
                   body: "\n## Bing\n\nBong!\n",
                   layout: Blog.PageLayout,
                   permalink: "/page/2page02/28/bing-bong/",
                   __tableau_page_extension__: true
                 } = page_2,
                 %{
                   date: "2024-02-28",
                   file: ^dir <> "/my-second-page.md",
                   title: "My Second Page",
                   body: "\n## Now we're cooking\n\nwith gas!\n",
                   layout: Blog.PageLayout,
                   permalink: "/page/2page02/28/second-page/",
                   categories: "page",
                   __tableau_page_extension__: true
                 } = page_1
               ],
               graph: graph
             } = token

      vertices = Graph.vertices(graph)

      assert Enum.any?(vertices, fn v -> is_struct(v, Tableau.Page) and v.permalink == page_1.permalink end)
      assert Enum.any?(vertices, fn v -> is_struct(v, Tableau.Page) and v.permalink == page_2.permalink end)
      assert Enum.any?(vertices, fn v -> v == Blog.PageLayout end)
    end

    test "configured permalink works when you dont specify one", %{tmp_dir: dir, token: token} do
      File.write(Path.join(dir, "my-future-page.md"), """
      ---
      layout: Blog.PageLayout
      title: A Great page
      date: 2018-02-28
      ---

      A great page
      """)

      assert {:ok, config} = PageExtension.config(%{dir: dir, enabled: true, permalink: "/page/:title"})

      token = put_in(token.extensions.pages.config, config)

      assert {:ok, token} = PageExtension.run(token)

      assert %{
               pages: [
                 %{
                   date: "2018-02-28",
                   file: ^dir <> "/my-future-page.md",
                   title: "A Great page",
                   body: "\nA great page\n",
                   layout: Blog.PageLayout,
                   __tableau_page_extension__: true,
                   permalink: "/page/a-great-page"
                 }
               ]
             } = token
    end

    test "generates permalink from file path if not configured or in front matter", %{tmp_dir: dir, token: token} do
      fancy_dir = Path.join(dir, "/some/fancy/path")
      File.mkdir_p!(fancy_dir)

      File.write(Path.join(fancy_dir, "a-deeply-nested-page.md"), """
      ---
      layout: Blog.PageLayout
      title: A Deeply Nested page
      ---

      A great page
      """)

      assert {:ok, token} = PageExtension.run(token)

      assert %{
               pages: [
                 %{
                   __tableau_page_extension__: true,
                   body: "\nA great page\n",
                   file: ^dir <> "/some/fancy/path/a-deeply-nested-page.md",
                   layout: Blog.PageLayout,
                   permalink: "/some/fancy/path/a-deeply-nested-page",
                   title: "A Deeply Nested page"
                 }
               ]
             } = token
    end

    test "handles fancy characters in permalink", %{tmp_dir: dir, token: token} do
      File.write(Path.join(dir, "a-page.md"), """
      ---
      layout: Blog.PageLayout
      title: ¿Qué es la programación funcional?
      permalink: /:title
      ---

      A great page
      """)

      assert {:ok, token} = PageExtension.run(token)

      assert %{
               pages: [
                 %{
                   __tableau_page_extension__: true,
                   body: "\nA great page\n",
                   file: ^dir <> "/a-page.md",
                   layout: Blog.PageLayout,
                   permalink: "/%C2qu%C3-es-la-programaci%C3n-funcional",
                   title: "¿Qué es la programación funcional?"
                 }
               ]
             } = token
    end

    test "handles frontmatter data in the permalink", %{tmp_dir: dir, token: token} do
      File.write(Path.join(dir, "a-page.md"), """
      ---
      title: foo man chu_foo.js
      type: articles
      layout: Some.Layout
      permalink: /:type/:title
      ---

      A great page
      """)

      assert {:ok, token} = PageExtension.run(token)

      assert %{
               pages: [
                 %{
                   __tableau_page_extension__: true,
                   body: "\nA great page\n",
                   file: ^dir <> "/a-page.md",
                   layout: Some.Layout,
                   permalink: "/articles/foo-man-chu-foo.js",
                   title: "foo man chu_foo.js",
                   type: "articles"
                 }
               ]
             } = token
    end
  end
end
