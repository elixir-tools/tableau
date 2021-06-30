defmodule Tableau.Watcher do
  use GenServer

  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(_args) do
    FileSystem.subscribe(:tableau_file_watcher)

    {:ok, %{}}
  end

  def handle_info({:file_event, _watcher_pid, {path, _event}}, state) do
    relative_path = Path.relative_to_cwd(path)

    post_data =
      for file <- File.ls!("./_posts") do
        {:ok, matter, body} = YamlFrontMatter.parse_file(Path.absname(file, "./_posts"))

        permalink =
          String.replace(matter["permalink"], ~r/:title/, matter["title"])
          |> String.replace(~r/[_\s]/, "-")

        Map.merge(matter, %{permalink: permalink, content: body})
      end

    case Path.extname(path) do
      ".ex" ->
        {time, _} =
          :timer.tc(fn ->
            mod = Tableau.compile_file(path)
            Tableau.build(mod, %{posts: post_data})
          end)

        Logger.debug("Built #{relative_path} in: #{time / 1000}ms")

      ".md" ->
        {:ok, matter, body} = YamlFrontMatter.parse_file(path)

        permalink =
          String.replace(matter["permalink"], ~r/:title/, matter["title"])
          |> String.replace(~r/[_\s]/, "-")

        data = Map.merge(matter, %{permalink: permalink, content: body})
        {time, _} = :timer.tc(fn -> Tableau.build_post(data) end)

        Logger.debug("Built #{relative_path} in: #{time / 1000}ms")

      _ ->
        :noop
    end

    {:noreply, state}
  end

  def handle_info(message, state) do
    Logger.debug("Unhandled message: #{inspect(message)}")
    {:noreply, state}
  end
end
