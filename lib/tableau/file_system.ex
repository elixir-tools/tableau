defmodule Tableau.FileSystem do
  def child_spec(_) do
    file_system_opts =
      Keyword.merge([dirs: [Path.absname("")]], name: :tableau_file_watcher, latency: 0)

    %{
      id: FileSystem,
      start: {FileSystem, :start_link, [file_system_opts]}
    }
  end
end
