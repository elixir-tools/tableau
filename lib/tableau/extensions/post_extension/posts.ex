defmodule Tableau.PostExtension.Posts do
  @moduledoc false
  alias Tableau.Extension.Common

  @config Map.new(Application.compile_env(:tableau, Tableau.PostExtension, %{}))

  def __tableau_type__, do: :pages

  def pages(opts \\ []) do
    opts
    |> posts()
    |> Enum.map(fn post ->
      %{
        type: :page,
        parent: post.layout,
        permalink: post.permalink,
        template: post.body,
        opts: post
      }
    end)
  end

  def posts(opts \\ []) do
    {:ok, config} =
      Tableau.PostExtension.Config.new(@config)

    opts =
      Keyword.put_new_lazy(opts, :html_converter, fn ->
        Module.concat([config.html_converter])
      end)

    config.dir
    |> Path.join("**/*.md")
    |> Common.paths()
    |> Common.entries(Tableau.PostExtension.Posts.Post, Tableau.PostExtension.Posts.Post, opts)
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
