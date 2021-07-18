# module mostly taken from `Phoenix.Endpoint.Watcher`

defmodule Tableau.Assets do
  @moduledoc false
  require Logger

  def child_spec(args) do
    %{
      id: make_ref(),
      start: {__MODULE__, :start_link, [args]},
      restart: :transient
    }
  end

  def start_link({cmd, args, opts}) do
    Task.start_link(__MODULE__, :watch, [to_string(cmd), args, opts])
  end

  def async({cmd, args, opts}) do
    Task.async(__MODULE__, :watch, [to_string(cmd), args, opts])
  end

  def watch(cmd, args, opts) do
    merged_opts =
      Keyword.merge(
        [into: IO.stream(:stdio, :line), stderr_to_stdout: true],
        opts
      )

    try do
      System.cmd(cmd, args, merged_opts)
    catch
      :error, :enoent ->
        relative = Path.relative_to_cwd(cmd)

        Logger.error(
          "Could not start watcher #{inspect(relative)} from #{inspect(cd(merged_opts))}, executable does not exist"
        )

        exit(:shutdown)
    else
      {_, 0} ->
        :ok

      {_, _} ->
        # System.cmd returned a non-zero exit code
        # sleep for a couple seconds before exiting to ensure this doesn't
        # hit the supervisor's max_restarts / max_seconds limit
        Process.sleep(2000)
        exit(:watcher_command_error)
    end
  end

  defp cd(opts), do: opts[:cd] || File.cwd!()
end
