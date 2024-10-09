defmodule Tableau.PageExtension.Pages do
  @moduledoc false
  alias Tableau.Extension.Common

  @config Map.new(Application.compile_env(:tableau, Tableau.PageExtension, %{}))

  def pages(opts \\ []) do
    {:ok, config} =
      Tableau.PageExtension.Config.new(@config)

    opts = Keyword.put_new(opts, :html_converter, Tableau.PageExtension.Pages.HTMLConverter)

    config.dir
    |> Path.join("**/*.md")
    |> Common.paths()
    |> Common.entries(Tableau.PageExtension.Pages.Page, Tableau.PageExtension.Pages.Page, opts)
  end
end
