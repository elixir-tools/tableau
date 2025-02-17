defmodule Tableau.DevServerTest.InnerLayout do
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

defmodule Tableau.DevServerTest.HomePage do
  @moduledoc false
  use Tableau.Page,
    layout: Tableau.DevServerTest.InnerLayout,
    permalink: "/home"

  def template(_), do: "Hello, World!"
end

defmodule Tableau.DevServerTest.BrokenExtension do
  @moduledoc false
  use Tableau.Extension, key: :pages, type: :pre_build, priority: 1, enabled: false

  def run(_token), do: raise "I'm broken"
end

defmodule Tableau.DevServerTest do
  use ExUnit.Case, async: false

  use Plug.Test
  #import Tableau.TestHelpers
  import ExUnit.CaptureLog
  import ExUnit.CaptureIO
  alias TableauDevServer.{Router, IndexHtml}

  @router_opts Router.init([])
  @indexhtml_opts IndexHtml.init([])

  setup do
    # disable extensions to suppress IO writes
    Application.put_env(:tableau, Mix.Tasks.Tableau.LogExtension, enabled: false)
    Application.put_env(:tableau, Mix.Tasks.Tableau.FailExtension, enabled: false)

    on_exit(fn ->
      Application.put_env(:tableau, Mix.Tasks.Tableau.LogExtension, enabled: true)
      Application.put_env(:tableau, Mix.Tasks.Tableau.FailExtension, enabled: true)
    end)
  end

  test "it serves the site" do
    conn =
      conn(:get, "/home")
      |> Router.call(@router_opts)

    assert conn.status == 200
    assert conn.resp_body =~ "Hello, World!"
  end

  test "it serves a 404 for missing pages" do
    assert capture_log(fn ->
             conn = conn(:get, "/missing")
             |> Router.call(@router_opts)

             assert conn.status == 404
             assert conn.resp_body =~ "Not Found"
           end) =~ "[error] File not found: /missing/index.html"
  end

  test "it serves a 500 when compiler crashes" do
    Application.put_env(:tableau, Tableau.DevServerTest.BrokenExtension, enabled: true)
    {conn, _log} = with_io(:stdio, fn ->
     conn(:get, "/home")
      |> Router.call(@router_opts)
    end)

    Application.delete_env(:tableau, Tableau.DevServerTest.BrokenExtension)
    assert conn.status == 500
    assert conn.resp_body =~ "Tableau Compilation error"
    assert conn.resp_body =~ "Console output is shown below"

  end

  test "index.html is serverd always when request path is directory" do
    conn =
      conn(:get, "/contact")
      |> IndexHtml.call(@indexhtml_opts)

    assert conn.path_info == ["contact", "index.html"]

    conn =
      conn(:get, "/very/deep/path/")
      |> IndexHtml.call(@indexhtml_opts)

    assert conn.path_info == ["very", "deep", "path", "index.html"]

    conn =
      conn(:get, "/assets/style.css")
      |> IndexHtml.call(@indexhtml_opts)

    assert conn.path_info == ["assets", "style.css"]
  end
end
