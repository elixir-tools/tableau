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
      end)

    {asset_time, _} =
      :timer.tc(fn ->
        for {mod, args} <- Tableau.Application.asset_children() do
          mod.async(args)
        end
        |> Task.await_many(60_000)
      end)

    tab_text = "Tableau built in: #{time / 1000}ms"
    asset_text = "Assets built in: #{asset_time / 1000}ms"
    text_length = Enum.max([String.length(tab_text), String.length(asset_text)])

    tab_text = String.pad_trailing(tab_text, text_length)
    asset_text = String.pad_trailing(asset_text, text_length)

    box_string = String.duplicate("═", text_length + 2)

    Logger.debug("""

    ╔#{box_string}╗
    ║ #{tab_text} ║
    ╠#{box_string}╣
    ║ #{asset_text} ║
    ╚#{box_string}╝
    """)
  end
end
