defmodule Tableau.LiveReload do
  @moduledoc false
  require Logger

  def init(opts \\ []) do
    name = Keyword.get(opts, :name, :tableau_file_watcher)

    FileSystem.subscribe(name)
  end

  def reload!({:file_event, _watcher_pid, {path, _event}}, opts \\ []) do
    patterns = Keyword.get(opts, :patterns, [])
    debounce = Keyword.get(opts, :debounce, 0)
    callback = Keyword.get(opts, :callback, &Function.identity/1)

    if matches_any_pattern?(path, patterns) do
      ext = Path.extname(path)

      for {path, ext} <- [{path, ext} | debounce(debounce, [ext], patterns)] do
        asset_type = remove_leading_dot(ext)
        Logger.debug("Live reload: #{Path.relative_to_cwd(path)}")

        callback.(path)

        send(self(), {:reload, asset_type})
      end
    end
  end

  defp debounce(0, _exts, _patterns), do: []

  defp debounce(time, exts, patterns) when is_integer(time) and time > 0 do
    Process.send_after(self(), :debounced, time)
    debounce(exts, patterns)
  end

  defp debounce(exts, patterns) do
    receive do
      :debounced ->
        []

      {:file_event, _pid, {path, _event}} ->
        ext = Path.extname(path)

        if matches_any_pattern?(path, patterns) and ext not in exts do
          [{path, ext} | debounce([ext | exts], patterns)]
        else
          debounce(exts, patterns)
        end
    end
  end

  defp matches_any_pattern?(path, patterns) do
    path = to_string(path)

    Enum.any?(patterns, fn pattern ->
      String.match?(path, pattern) and not String.match?(path, ~r{(^|/)_build/})
    end)
  end

  defp remove_leading_dot("." <> rest), do: rest
  defp remove_leading_dot(rest), do: rest
end
