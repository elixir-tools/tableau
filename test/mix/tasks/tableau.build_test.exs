defmodule Mix.Tasks.Tableau.LogExtension do
  @moduledoc false
  use Tableau.Extension, key: :log, type: :pre_build, priority: 200

  def run(token) do
    IO.write(:stderr, "second: #{System.monotonic_time()}\n")
    {:ok, token}
  end
end

defmodule Mix.Tasks.Tableau.FailExtension do
  @moduledoc false
  use Tableau.Extension, key: :fail, type: :pre_build, priority: 100

  def run(_site) do
    IO.write(:stderr, "first: #{System.monotonic_time()}\n")
    :error
  end
end

defmodule Mix.Tasks.Tableau.FooExtension do
  @moduledoc false
  use Tableau.Extension, key: :foo, type: :pre_write, priority: 100

  def run(token) do
    pages =
      for page <- token.site.pages do
        Map.put(page, :foo, "bar")
      end

    {:ok, put_in(token.site.pages, pages)}
  end
end

defmodule Mix.Tasks.Tableau.BuildTest.About do
  @moduledoc false
  alias Mix.Tasks.Tableau.BuildTest.InnerLayout

  require EEx

  def __tableau_type__, do: :page
  def __tableau_parent__, do: InnerLayout
  def __tableau_permalink__, do: "/about"
  def __tableau_opts__, do: []

  EEx.function_from_string(
    :def,
    :template,
    ~s'''
    <div>
      hi
    </div>
    ''',
    [:_assigns]
  )
end

defmodule Mix.Tasks.Tableau.BuildTest.Index do
  @moduledoc false

  alias Mix.Tasks.Tableau.BuildTest.InnerLayout

  require EEx

  def __tableau_type__, do: :page
  def __tableau_parent__, do: InnerLayout
  def __tableau_permalink__, do: "/"
  def __tableau_opts__, do: []

  EEx.function_from_string(
    :def,
    :template,
    ~s'''
    <div id="home">
      Home page!
    </div>
    ''',
    [:_assigns]
  )
end

defmodule Mix.Tasks.Tableau.BuildTest.InnerLayout do
  @moduledoc false
  import Tableau.Document.Helper, only: [render: 1]

  alias Mix.Tasks.Tableau.BuildTest.RootLayout

  require EEx

  def __tableau_type__, do: :layout
  def __tableau_parent__, do: RootLayout

  EEx.function_from_string(
    :def,
    :template,
    ~s'''
    <div id="inner-layout">
      <%= render(@inner_content) %>
    </div>
    ''',
    [:assigns]
  )
end

defmodule Mix.Tasks.Tableau.BuildTest.RootLayout do
  @moduledoc false
  import Tableau.Document.Helper, only: [render: 1]

  require EEx

  def __tableau_type__, do: :layout

  EEx.function_from_string(
    :def,
    :template,
    ~s'''
    <html>
      <head></head>
      <body>
        <%= render @inner_content %>
      </body>
    </html>
    ''',
    [:assigns]
  )
end

defmodule Mix.Tasks.Tableau.BuildTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO
  import ExUnit.CaptureLog

  alias Mix.Tasks.Tableau.Build

  @tag :tmp_dir
  test "renders all pages", %{tmp_dir: out} do
    posts = out |> Path.join("_posts") |> tap(&File.mkdir_p!/1)
    pages = out |> Path.join("_pages") |> tap(&File.mkdir_p!/1)
    Application.put_env(:tableau, Tableau.PostExtension, enabled: true, dir: posts)
    Application.put_env(:tableau, Tableau.PageExtension, enabled: true, dir: pages)

    File.write(Path.join(posts, "my-post.md"), """
    ---
    layout: Mix.Tasks.Tableau.BuildTest.RootLayout
    title: A Bing Bong Blog Post
    date: 2017-02-28
    categories: post
    permalink: /:title/
    ---

    ## Bing

    Bong!
    """)

    page_path = pages |> Path.join("some/deeply/nested/page") |> tap(&File.mkdir_p!/1) |> Path.join("/my-page.md")

    File.write(page_path, """
    ---
    layout: Mix.Tasks.Tableau.BuildTest.RootLayout
    title: Beginner Tutorial
    ---

    ## How to get started
    """)

    {log, io} =
      with_io(:stderr, fn ->
        {_, log} =
          with_log(fn ->
            _documents = Build.run(["--out", out])
          end)

        log
      end)

    assert [{"first", first}, {"second", second}] =
             io
             |> String.split("\n", trim: true)
             |> Enum.map(fn line ->
               [order, time] =
                 Regex.run(~r/^(first|second): (.*)$/, line, capture: :all_but_first)

               {order, String.to_integer(time)}
             end)

    assert first < second

    assert log =~ "FailExtension failed to run"

    assert File.exists?(Path.join(out, "/index.html"))
    assert File.exists?(Path.join(out, "/about/index.html"))
    assert File.exists?(Path.join(out, "/a-bing-bong-blog-post/index.html"))
    assert File.exists?(Path.join(out, "/some/deeply/nested/page/my-page/index.html"))
  end
end
