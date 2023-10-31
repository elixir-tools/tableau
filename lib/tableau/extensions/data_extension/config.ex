defmodule Tableau.DataExtension.Config do
  @moduledoc false
  import Schematic

  defstruct enabled: true, dir: "_data"

  def new(input), do: unify(schematic(), input)

  def schematic do
    schema(
      __MODULE__,
      %{
        optional(:enabled) => bool(),
        optional(:dir) => str()
      },
      convert: false
    )
  end
end
