defmodule Tableau.StoreTest do
  use ExUnit.Case, async: true

  @moduletag :tmp_dir
  alias Tableau.Store

  defmodule TestSite do
    defmodule Index do
      use Tableau.Page
      import Temple

      def render(assigns) do
        temple do
          div do
            "this is the home page 👍"
          end
        end
      end
    end

    defmodule Books do
      use Tableau.Data

      data :books do
        [
          %{title: "Jurassic Park", author: "Michael Crichton"},
          %{title: "The Lost World", author: "Michael Crichton"},
          %{title: "Congo", author: "Michael Crichton"}
        ]
      end
    end

    defmodule Projects do
      use Tableau.Data, base_dir: Path.expand("test/support/fixtures/_data")

      yaml(:projects)
    end
  end

  setup %{tmp_dir: tmp_dir} do
    base_write_dir = Path.join(tmp_dir, "_site")

    store =
      start_supervised!(
        {Tableau.Store,
         [
           base_post_path: Path.expand("test/support/fixtures/_posts"),
           base_dir: base_write_dir
         ]}
      )

    expected_post = %Tableau.Post{
      content: "\n# Hi!\n\nThis is an intro\n",
      frontmatter: %{"permalink" => "/:title", "title" => "Intro to tableau"},
      layout: Tableau.Layouts.App,
      path: "/Users/mitchell/src/tableau/test/support/fixtures/_posts/intro.md",
      permalink: "/Intro-to-tableau"
    }

    expected_page = %Tableau.Page{
      permalink: "/storetest/testsite/index",
      data: %{
        books: [
          %{title: "Jurassic Park", author: "Michael Crichton"},
          %{title: "The Lost World", author: "Michael Crichton"},
          %{title: "Congo", author: "Michael Crichton"}
        ]
      },
      md5: nil,
      module: Tableau.StoreTest.TestSite.Index,
      posts: [expected_post]
    }

    [store: store, page: expected_page, post: expected_post, base_write_dir: base_write_dir]
  end

  describe "init" do
    test "writes pages on bootup", %{page: page, post: post, base_write_dir: base_write_dir} do
      assert File.read!(Path.join([base_write_dir, page.permalink, "index.html"])) =~
               "<div>\n  this is the home page 👍\n</div>"

      assert File.read!(Path.join([base_write_dir, post.permalink, "index.html"])) =~
               "This is an intro"
    end
  end

  describe "all/0" do
    test "works", %{store: store, post: post, page: page} do
      pages = Store.all()

      assert page in pages
      assert post in pages
    end
  end

  describe "posts/0" do
    test "returns all the posts", %{post: post} do
      posts = Store.posts()

      assert [post] == posts
    end
  end

  describe "data/0" do
    test "works" do
      data = Store.data()

      assert data == %{
               books: [
                 %{author: "Michael Crichton", title: "Jurassic Park"},
                 %{author: "Michael Crichton", title: "The Lost World"},
                 %{author: "Michael Crichton", title: "Congo"}
               ],
               projects: []
             }
    end
  end
end
