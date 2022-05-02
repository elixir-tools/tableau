defmodule Mix.Tasks.Tableau.Build do
  use Mix.Task

  require Logger

  @cache :tableau_store_cache

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

    {asset_time, _} =
      :timer.tc(fn ->
        for {mod, conf} <- Tableau.Application.asset_children() do
          apply(mod, :start_link, [conf])
        end
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
