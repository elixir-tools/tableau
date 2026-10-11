defmodule Tableau.MDExExtension do
  @moduledoc """
  Converter to parse markdown content with `MDEx`.

  > #### Warning {: .warning}
  > [MDEx](https://github.com/leandrocp/mdex), [mdex_native](https://github.com/leandrocp/mdex_native), and [Lumis](https://github.com/leandrocp/lumis) are constantly evolving projects that change quickly. This module only relies on the `MDEx.to_html/2` function, so breaking changes are unlikely from a Tableau perspective, but if you update any of these libraries, you must check for breaking configuration changes and update your site accordingly.

  Configure `MDEx` options (these are passed directly to `MDEx.to_html/2`) with:

  ```elixir
  config :mdex_native, :syntax_highlighter, :lumis

  config :tableau, Tableau.MDExExtension,
    extension: [
      table: true,
      header_id_prefix: "",
      tasklist: true,
      strikethrough: true,
      autolink: true,
      alerts: true,
      footnotes: true
    ],
    render: [unsafe: true],
    syntax_highlight: [
      engine: :lumis,
      opts: [
        formatter: {:html_inline, theme: "neovim_dark"}
      ]
    ]
  ```

  ### Syntax Highlighting

  > #### mdex_native {: .tip}
  > MDEx allows you to highlight your code with [Lumis](https://github.com/leandrocp/lumis/) or [Syntect](https://docs.rs/syntect/latest/syntect/). Lumis requires you to add `:lumis` to your dependencies (Syntect does not require this).
  >
  > You need to configure `:mdex_native` which syntax highlighter to use.
  > ```elixir
  > # config/config.exs
  >
  > config :mdex_native, :syntax_highlighter, :lumis
  > # or
  > config :mdex_native, :syntax_highlighter, :syntect
  > ```

  #### Lumis

  Lumis requires you to install the `:lumis` dependency as well as the parsers as dependencies as well. You can see the documentation for this [here](https://docs.lumis.sh/).

  In addition to setting the `:mdex_native` configuration, you must also configure the `:engine` option for `:mdex`

  You can find full configuration optiosn in the MDEx documentation.

  ```elixir
  # mix.exs
  defp deps() do
    [
      {:lumis, "~> 0.10"},
    ]
  end

  # config/config.exs
  config :mdex_native, :syntax_highlighter, :lumis

  config :tableau, Tableau.MDExExtension,
    syntax_highlight: [
      engine: :lumis,
      opts: [
        formatter: {:html_inline, theme: "neovim_dark"}
      ]
    ]
  ```

  #### Syntect

  In addition to setting the `:mdex_native` configuration, you must also configure the `:engine` option for `:mdex`

  You can find full configuration optiosn in the MDEx documentation.

  ```elixir
  # config/config.exs
  config :mdex_native, :syntax_highlighter, :syntect

  config :tableau, Tableau.MDExExtension,
    syntax_highlight: [
      engine: :syntect,
      opts: [
        theme: "Catppuccin Macchiato"
      ]
    ]
  ```
  """

  use Tableau.Extension, key: :mdex

  @impl true
  def convert(body, config_overrides \\ []) do
    if Code.ensure_loaded?(MDEx) do
      config =
        :tableau
        |> Application.get_env(__MODULE__, [])
        |> Keyword.merge(config_overrides)

      MDEx.to_html!(body, config)
    else
      raise """
      MDEx is not installed!

      You'll need to add `:mdex` as a dependency in mix.exs.

      `{:mdex, "~> 0.14"}`
      """
    end
  end
end
