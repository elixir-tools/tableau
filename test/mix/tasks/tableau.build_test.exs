defmodule Mix.Tasks.Tableau.LogExtension do
  @moduledoc false
  use Tableau.Extension, key: :log, type: :pre_build, priority: 200

  defmodule Config do
    @moduledoc false
    def new(i), do: {:ok, i}
  end

  def run(token) do
    IO.inspect(System.monotonic_time(), label: "second")
    {:ok, token}
  end
end

defmodule Mix.Tasks.Tableau.FailExtension do
  @moduledoc false
  use Tableau.Extension, key: :fail, type: :pre_build, priority: 100

  def run(_site) do
    IO.inspect(System.monotonic_time(), label: "first")
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
  import Tableau.Strung

  alias Mix.Tasks.Tableau.BuildTest.InnerLayout

  require EEx

  def __tableau_type__, do: :page
  def __tableau_parent__, do: InnerLayout
  def __tableau_permalink__, do: "/about"
  def __tableau_opts__, do: []

  EEx.function_from_string(
    :def,
    :template,
    ~g'''
    <div>
      hi
    </div>
    '''html,
    [:_assigns]
  )
end

defmodule Mix.Tasks.Tableau.BuildTest.Index do
  @moduledoc false
  import Tableau.Strung

  alias Mix.Tasks.Tableau.BuildTest.InnerLayout

  require EEx

  def __tableau_type__, do: :page
  def __tableau_parent__, do: InnerLayout
  def __tableau_permalink__, do: "/"
  def __tableau_opts__, do: []

  EEx.function_from_string(
    :def,
    :template,
    ~g'''
    <div id="home">
      Home page!
    </div>
    '''html,
    [:_assigns]
  )
end

defmodule Mix.Tasks.Tableau.BuildTest.InnerLayout do
  @moduledoc false
  import Tableau.Document.Helper, only: [render: 1]
  import Tableau.Strung

  alias Mix.Tasks.Tableau.BuildTest.RootLayout

  require EEx

  def __tableau_type__, do: :layout
  def __tableau_parent__, do: RootLayout

  EEx.function_from_string(
    :def,
    :template,
    ~g'''
    <div id="inner-layout">
      <%= render(@inner_content) %>
    </div>
    '''html,
    [:assigns]
  )
end

defmodule Mix.Tasks.Tableau.BuildTest.RootLayout do
  @moduledoc false
  import Tableau.Document.Helper, only: [render: 1]
  import Tableau.Strung

  require EEx

  def __tableau_type__, do: :layout

  EEx.function_from_string(
    :def,
    :template,
    ~g'''
    <html>
      <head></head>
      <body>
        <%= render @inner_content %>
      </body>
    </html>
    '''html,
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
    {log, io} =
      with_io(fn ->
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
  end
end
