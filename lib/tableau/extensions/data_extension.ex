defmodule Tableau.DataExtension.Config do
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

defmodule Tableau.DataExtension do
  use Tableau.Extension, key: :data, type: :pre_build, priority: 200

  def run(token) do
    data =
      for file <- Path.wildcard(Path.join(token.data.dir, "**/*.{yml,yaml}")), into: %{} do
        key =
          file
          |> Path.basename(".yaml")
          |> Path.basename(".yml")

        {key, YamlElixir.read_from_file!(file)}
      end

    {:ok, Map.put(token, :data, data)}
  end
end
