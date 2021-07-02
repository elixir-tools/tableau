defmodule Mix.Tasks.Tableau.Build do
  use Mix.Task

  alias Tableau.Store

  require Logger

  @moduledoc "Task to build the tableau site"
  @shortdoc "Builds the site"

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("compile")
    Application.ensure_all_started(:tableau)

    {time, _} =
      :timer.tc(fn ->
        site = Store.fetch()

        site.posts
        |> Map.merge(site.pages)
        |> Task.async_stream(fn {_, page} ->
          unless Tableau.Renderable.layout?(page) do
            Tableau.Renderable.render(page)
          end
        end)
        |> Stream.run()
      end)

    Logger.debug("Built in: #{time / 1000}ms")
  end
end
