defmodule Tableau.PageExtension.Config do
  @moduledoc false

  import Schematic

  defstruct enabled: true,
            dir: "_pages",
            permalink: nil,
            layout: nil,
            html_converter: "Tableau.PostExtension.Posts.HTMLConverter"

  def new(input), do: unify(schematic(), input)

  def schematic do
    schema(
      __MODULE__,
      %{
        optional(:enabled) => bool(),
        optional(:dir) => str(),
        optional(:permalink) => str(),
        optional(:layout) => str(),
        optional(:html_converter) => str()
      },
      convert: false
    )
  end
end
