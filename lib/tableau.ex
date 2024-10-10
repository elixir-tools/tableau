defmodule Tableau do
  @moduledoc """
  ## Global Site Configuration

  * `:include_dir` - string - Directory that is just copied to the output directory. Defaults to `extra`.
  * `:timezone` - string - Timezone to use when parsing date times. Defaults to `Etc/UTC`.
  * `:base_path` - string - Development server root.  Defaults to '/'.
  * `:url` - string (required) - The URL of your website.
  * `:converters` - mapping of file extensions to converter module. Defaults to `[md: Tableau.MDExConverter]`
  * `:markdown` - keyword
      * `:mdex` - keyword - Options to pass to `MDEx.to_html/2`

  ### Example

  ```elixir
  # configs/config.exs
  config :tableau, :config,
    url: "http://localhost:8080",
    timezone: "America/Indiana/Indianapolis",
    converters: [
      md: Tableau.MDExConverter,
      dj: MySite.DjotConverter
    ],
    markdown: [
      mdex: [
        extension: [table: true, header_ids: "", tasklist: true, strikethrough: true],
        render: [unsafe_: true],
        features: [syntax_highlight_theme: "kanagawa"]
      ]
    ]
  ```
  """

  @doc """
  Component to connect to the development server via websocket to broadcast that the page should reload.

  By default, connects to `'ws://' + location.host + '/ws'`.

  See `WebDevUtils` for configuration options.
  """
  defdelegate live_reload(assigns), to: WebDevUtils.Components

  @doc """
  Convert markdown content to HTML using `MDEx.to_html!/2`.

  Will use the globally configured options, but you can also pass it overrides.
  """
  def markdown(content, overrides \\ []) do
    {:ok, config} = Tableau.Config.get()

    MDEx.to_html!(content, Keyword.merge(config.markdown[:mdex], overrides))
  end
end
