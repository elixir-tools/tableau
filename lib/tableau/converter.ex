defmodule Tableau.Converter do
  @moduledoc """
  Convenience module for converting content into HTML. Useful for extension authors to convert content consistently with other
  extensions without making beskope code.

  By default, will convert markdown content into HTML using `Tableau.MDExExtension`.

  You can configure other converters (an extension that implements the convert callback) with:

  ```elixir
  config :tableau, :config,
    converters: [
      ext: ConverterModule
    ]
  ```

  This will be merged in with the default of `[md: Tableau.MDExExtension]`.

  This can be called via an explicit converter or with an extension that will be looked up via the configuration.

  ```elixir
  Tableau.Converter.convert(content, converter: MyConverter)

  Tableau.Converter.convert(content, ext: :md)
  ```

  This makes it somewhat easier to swap out your converter without needing to make big application changes, but you can still
  call a converter explicitly in your layout/page code. Doing so will allow you to pass configuration options to the
  converter itself (assuming the implementation allows that).

  ```elixir
  Tableau.MDExExtension.convert(content, extension: [autolink: false])
  ```
  """
  @default_converters [
    md: Tableau.MDExExtension
  ]
  def convert(content, opts \\ []) do
    converters =
      Keyword.merge(
        @default_converters,
        Application.get_env(:tableau, :config, [])[:converters] || []
      )

    with nil <- opts[:converter],
         nil <- converters[opts[:ext]] do
      content
    else
      converter -> converter.convert(content)
    end
  end
end
