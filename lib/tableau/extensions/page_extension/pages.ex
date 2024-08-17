defmodule Tableau.PageExtension.Pages do
  @moduledoc false
  alias Tableau.Extension.Common

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

    opts =
      Keyword.put_new_lazy(opts, :html_converter, fn ->
        Module.concat([config.html_converter])
      end)

    config.dir
    |> Path.join("**/*.md")
    |> Common.paths()
    |> Common.entries(Tableau.PageExtension.Pages.Page, Tableau.PageExtension.Pages.Page, opts)
  end
end
