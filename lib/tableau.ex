defmodule Tableau do
  @moduledoc """
  ## Global Site Configuration

  * `:include_dir` - string - Directory that is just copied to the output directory. Defaults to `extra`.
  * `:out_dir` - string - The directory to output your website to. Defaults to `_site`.
  * `:timezone` - string - Timezone to use when parsing date times. Defaults to `Etc/UTC`.
  * `:base_path` - string - Development server root.  Defaults to '/'.
  * `:url` - string (required) - The URL of your website.
  * `:converters` - mapping of file extensions to converter module. Defaults to `[md: Tableau.MDExExtension]`
  * `:slug` - keyword - Options to pass to `Slug.slugify/2`

  You'll want to check out each extension's documentation to see configuration options.

  ### Example

  ```elixir
  # config/config.exs

  import Config

  config :tableau, :config,
    url: "http://localhost:8080",
    timezone: "America/Indiana/Indianapolis",
    converters: [
      md: Tableau.MDExExtension,
      dj: MySite.DjotConverter
    ],
    slug: [
      lowercase: false
    ]
  ```
  """
end
