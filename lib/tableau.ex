defmodule Tableau do
  @moduledoc """
  ## Global Site Configuration

  * `:include_dir` - string - Directory that is just copied to the output directory. Defaults to `extra`.
  * `:timezone` - string - Timezone to use when parsing date times. Defaults to `Etc/UTC`.
  * `:url` - string (required) - The URL of your website.
  * `:markdown` - keyword
      * `:mdex` - keyword - Options to pass to `MDEx.to_html/2`
  """

  @doc """
  Component to connect to the development server via websocket to broadcast that the page should reload.

  By default, connects to `'ws://' + location.host + '/ws'`.

  See `WebDevUtils` for configuration options.
  """
  defdelegate live_reload(assigns), to: WebDevUtils.Components

  @doc """
  Convert markdown content to HTML using `MDEx.to_html/2`.

  Will use the globally configured options, but you can also pass it overrides.
  """
  def markdown(content, overrides \\ []) do
    {:ok, config} = Tableau.Config.new(Map.new(Application.get_env(:tableau, :config, %{})))

    MDEx.to_html(content, Keyword.merge(config.markdown[:mdex], overrides))
  end
end
