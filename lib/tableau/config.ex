defmodule Tableau.Config do
  @moduledoc """
  Project configuration.

  * `:include_dir` - Directory that is just copied to the output directory. Defaults to `extra`.
  * `:timezone` - Timezone to use when parsing date times. Defaults to `Etc/UTC`.
  * `:url` - The URL of your website.
  * `:markdown` - keyword
      * `:mdex` - keyword - Options to pass to [MDEx](https://hexdocs.pm/mdex/MDEx.html#to_html/2)
  """

  import Schematic

  defstruct [
    :url,
    include_dir: "extra",
    timezone: "Etc/UTC",
    reload_log: false,
    markdown: [mdex: []]
  ]

  def new(config) do
    unify(schematic(), config)
  end

  defp schematic do
    schema(
      __MODULE__,
      %{
        optional(:include_dir) => str(),
        optional(:timezone) => str(),
        optional(:reload_log) => bool(),
        optional(:markdown) => list(oneof([tuple([:mdex, list()])])),
        url: str()
      },
      convert: false
    )
  end
end
