defmodule Tableau do
  @moduledoc """
  ## Global Site Configuration

  * `:include_dir` - string - Directory that is just copied to the output directory. Defaults to `extra`.
  * `:out_dir` - string - The directory to output your website to. Defaults to `_site`.
  * `:timezone` - string - Timezone to use when parsing date times. Defaults to `Etc/UTC`.
  * `:base_path` - string - Development server root.  Defaults to '/'.
  * `:url` - string (required) - The URL of your website.
  * `:converters` - mapping of file extensions to converter module. Defaults to `[md: Tableau.MDExConverter]`
  * `:markdown` - keyword
      * `:mdex` - keyword - Options to pass to `MDEx.to_html/2`
  * `:slug` - keyword - Options to pass to `Slug.slugify/2`

  ### Example

  ```elixir
  # config/config.exs

  import Config

  config :mdex_native, syntax_highlighter: :syntect

  config :tableau, :config,
    url: "http://localhost:8080",
    timezone: "America/Indiana/Indianapolis",
    converters: [
      md: Tableau.MDExConverter,
      dj: MySite.DjotConverter
    ],
    slug: [
      lowercase: false
    ],
    markdown: [
      mdex: [
        extension: [
          table: true,
          header_ids: "",
          tasklist: true,
          strikethrough: true,
          autolink: true,
          alerts: true,
          footnotes: true
        ],
        render: [unsafe: true],
        syntax_highlight: [engine: :syntect, theme: "Catppuccin Macchiato"],
        plugins: [MDExGFM]
      ]
    ]
  ```

  ### Syntax Highlighting

  MDEx provides two syntax highlighting engines: [Lumis][lumis] and [Syntect][syntact].
  The Syntect engine requires less configuration; it uses Sublime Text highlighting
  grammars (defined with regular expressions). Supported themes are part of the
  [two-face][2face] crate.

  The Lumis engine requires more configuration and a defined package for each of the
  languages rendered on your site.

  ```elixir
  # config/config.exs
  config :mdex_native, syntax_highlighter: :lumis

  config :tableau, :config,
    # …
    markdown: [
      # …
      syntax_highlight: [engine: :lumis, theme: "neovim_dark"]
    ]

  # mix.exs
  defp defps do
    [
      # …
      {:lumis, "~> 0.10"},
      {:lumis_wasm_elixir, "~> 0.26"},
      {:lumis_wasm_ruby, "~> 0.26"},
      {:lumis_wasm_rust, "~> 0.26"}
    ]
  end
  ```

  The full list of tree-sitter syntax parsers can be loaded using the [full][lumis-full]
  bundle, but note that Lumis enforces [highlighting budgets][lumis-budget] that can be
  configured.

  [2face]: https://crates.io/crates/two-face
  [lumis-budget]: https://mdex.hexdocs.pm/lumis.html#highlighting-budgets
  [lumis-full]: https://hex.pm/packages/lumis_wasm_bundle_full
  [lumis]: https://mdex.hexdocs.pm/lumis.html
  [syntect]: https://mdex.hexdocs.pm/syntect.html
  """

  @doc """
  Convert markdown content to HTML using `MDEx.to_html!/2`.

  Will use the globally configured options, but you can also pass it overrides.
  """
  def markdown(content, overrides \\ []) do
    {:ok, config} = Tableau.Config.get()

    MDEx.to_html!(content, Keyword.merge(config.markdown[:mdex], overrides))
  end
end
