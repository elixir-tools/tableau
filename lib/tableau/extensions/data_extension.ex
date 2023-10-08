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
      for file <- Path.wildcard(Path.join(token.data.dir, "**/*.{yml,yaml,exs}")), into: %{} do
        case Path.extname(file) do
          ".exs" ->
            key = file |> Path.basename(".exs")

            {result, _binding} = Code.eval_file(file)

            {key, result}

          yaml when yaml in ~w[.yml .yaml] ->
            key =
              file
              |> Path.basename(".yaml")
              |> Path.basename(".yml")

            {key, YamlElixir.read_from_file!(file)}
        end
      end

    {:ok, Map.put(token, :data, data)}
  end
end
