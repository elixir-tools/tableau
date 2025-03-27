defmodule Tableau.Config do
  @moduledoc false

  import Schematic

  defstruct [
    :url,
    base_path: "",
    include_dir: "extra",
    out_dir: "_site",
    timezone: "Etc/UTC",
    reload_log: false,
    converters: [md: Tableau.MDExConverter],
    markdown: [mdex: []]
  ]

  def new(config) do
    unify(schematic(), config)
  end

  def get do
    Tableau.Config.new(Map.new(Application.get_env(:tableau, :config, %{})))
  end

  defp schematic do
    schema(
      __MODULE__,
      %{
        optional(:include_dir) => str(),
        optional(:out_dir) => str(),
        optional(:timezone) => str(),
        optional(:reload_log) => bool(),
        optional(:converters) => keyword(values: atom()),
        optional(:markdown) => keyword(values: list()),
        optional(:base_path) => str(),
        url: str()
      },
      convert: false
    )
  end
end
