defmodule Tableau.PageExtension.Pages do
  @moduledoc false
  alias Tableau.Extension.Common
  alias Tableau.PageExtension.Pages.Page

  @config Map.new(Application.compile_env(:tableau, Tableau.PageExtension, %{}))

  def __tableau_type__, do: :pages

  def pages(opts \\ []) do
    opts
    |> pages2()
    |> Enum.map(fn page ->
      %{
        type: :page,
        parent: page.layout,
        permalink: page.permalink,
        template: page.body,
        opts: page
      }
    end)
  end

  def pages2(opts \\ []) do
    {:ok, config} =
      Tableau.PageExtension.Config.new(@config)

    opts = Keyword.put_new(opts, :html_converter, Tableau.PageExtension.Pages.HTMLConverter)

    config.dir
    |> Path.join("**/*.md")
    |> Common.paths()
    |> Common.entries(Page, Page, opts)
  end
end
