defmodule Mix.Tasks.Tableau.Build do
  use Mix.Task

  require Logger

  @moduledoc "Task to build the tableau site"
  @shortdoc "Builds the site"

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("compile")

    {time, _} =
      :timer.tc(fn ->
        posts = Tableau.Post.build(Path.expand("_posts"))

        Tableau.Page.build()
        |> Enum.concat(posts)
        |> Task.async_stream(fn page ->
          unless Tableau.Renderable.layout?(page) do
            Tableau.Renderable.render(page, posts: posts)
          end
        end)
        |> Stream.run()

        for {mod, args} <- Tableau.Application.asset_children() do
          mod.async(args)
        end
        |> Task.await_many(60_000)
      end)

    Logger.debug("Built in: #{time / 1000}ms")
  end
end
