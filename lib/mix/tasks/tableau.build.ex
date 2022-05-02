defmodule Mix.Tasks.Tableau.Build do
  use Mix.Task

  require Logger

  @cache :tableau_pages_cache

  @moduledoc "Task to build the tableau site"
  @shortdoc "Builds the site"

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("compile")
    Application.ensure_all_started(:telemetry)

    Tableau.Store.start_link(name: Tableau.Store)

    {time, _} =
      :timer.tc(fn ->
        Tableau.Post.build(Path.expand("_posts"), fn post ->
          Task.async(fn ->
            content = Tableau.Renderable.render(post)
            Mentat.put(@cache, post.permalink, {post, content})

            Tableau.Renderable.write!(post, content)
          end)
        end)
        |> Task.await_many()

        Tableau.Page.build(fn page ->
          Task.async(fn ->
            content = Tableau.Renderable.render(page)

            Tableau.Renderable.write!(page, content)
          end)
        end)
        |> Task.await_many()
      end)

    Logger.debug("Tableau built in: #{time / 1000}ms")
  end
end
