defmodule Tableau.RSSExtension.Config do
  @moduledoc false
  import Schematic

  defstruct [:title, :description, language: "en-us", enabled: true]

  def new(input), do: unify(schematic(), input)

  def schematic do
    schema(
      __MODULE__,
      %{
        optional(:enabled) => bool(),
        optional(:language) => str(),
        title: str(),
        description: str()
      },
      convert: false
    )
  end
end
