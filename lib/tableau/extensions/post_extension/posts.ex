defmodule Tableau.PostExtension.Posts do
  @moduledoc false
  alias Tableau.Extension.Common
  alias Tableau.PostExtension.Posts.Post

  @config Map.new(Application.compile_env(:tableau, Tableau.PostExtension, %{}))

  def posts(opts \\ []) do
    {:ok, config} =
      Tableau.PostExtension.Config.new(@config)

    {:ok, %{converters: converters}} = Tableau.Config.get()

    opts = Keyword.put_new(opts, :converters, converters)

    exts = Enum.map_join(converters, ",", fn {ext, _} -> to_string(ext) end)

    config.dir
    |> Path.join("**/*.{#{exts}}")
    |> Common.paths()
    |> Common.entries(Post, opts)
    |> Enum.sort_by(& &1.date, {:desc, DateTime})
    |> then(fn posts ->
      if config.future do
        posts
      else
        Enum.reject(posts, &DateTime.after?(&1.date, DateTime.utc_now()))
      end
    end)
  end
end
