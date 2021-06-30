defmodule Mix.Tasks.Tableau.Build do
  use Mix.Task

  require Logger

  @moduledoc "Task to build the tableau site"
  @shortdoc "Builds the site"

  @impl Mix.Task
  def run(_args) do
    Tableau.compile_all()

    {time, _} =
      :timer.tc(fn ->
        Logger.debug("Building!")

        post_data =
          for file <- File.ls!("./_posts") do
            {:ok, matter, body} = YamlFrontMatter.parse_file(Path.absname(file, "./_posts"))

            permalink =
              String.replace(matter["permalink"], ~r/:title/, matter["title"])
              |> String.replace(~r/[_\s]/, "-")

            Map.merge(matter, %{permalink: permalink, content: body})
          end

        pages =
          for {mod, _, _} <- :code.all_available(), tableau_page?(mod) do
            Task.async(fn ->
              mod
              |> to_string()
              |> String.to_existing_atom()
              |> Tableau.build(%{posts: post_data})
            end)
          end

        posts =
          for file <- post_data do
            Task.async(fn -> Tableau.build_post(file) end)
          end

        Task.await_many(pages ++ posts)

        nil
      end)

    Logger.debug("Built in: #{time / 1000}ms")
  end

  defp tableau_page?(mod) do
    String.match?(to_string(mod), ~r/Elixir\.#{Tableau.module_prefix()}\.Pages/)
  end
end
