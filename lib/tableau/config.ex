defmodule Tableau.Config do
  @moduledoc false

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
