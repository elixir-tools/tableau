defmodule Tableau.PostExtension.Config do
  @moduledoc false

  import Schematic

  defstruct enabled: true, dir: "_posts", future: false, permalink: nil, layout: nil, strip_h1_titles: false

  def new(input), do: unify(schematic(), input)

  def schematic do
    schema(
      __MODULE__,
      %{
        optional(:enabled) => bool(),
        optional(:dir) => str(),
        optional(:future) => bool(),
        optional(:permalink) => str(),
        optional(:layout) => str(),
        optional(:strip_h1_titles) => bool()
      },
      convert: false
    )
  end
end
