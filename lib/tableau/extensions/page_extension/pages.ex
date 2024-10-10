defmodule Tableau.PageExtension.Pages do
  @moduledoc false
  alias Tableau.Extension.Common
  alias Tableau.PageExtension.Pages.Page

  @config Map.new(Application.compile_env(:tableau, Tableau.PageExtension, %{}))

  def pages(opts \\ []) do
    {:ok, config} =
      Tableau.PageExtension.Config.new(@config)

    {:ok, %{converters: converters}} = Tableau.Config.get()

    opts = Keyword.put_new(opts, :converters, converters)

    exts = Enum.map_join(converters, ",", fn {ext, _} -> to_string(ext) end)

    config.dir
    |> Path.join("**/*.{#{exts}}")
    |> Common.paths()
    |> Common.entries(Page, opts)
  end
end
