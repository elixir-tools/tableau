defmodule Tableau.DataExtension do
  @moduledoc """
  YAML files and Elixir scripts (.exs) in the confgiured directory will be automatically parsed/executed and made available in an `@data` assign in your templates.

  Elixir scripts will be executed and the last expression returned as the data.

  ## Configuration

  - `:enabled` - boolean - Extension is active or not.
  - `:dir` - string - Directory to scan for data files. Defaults to `_data`

  ### Example

  ```elixir
  config :tableau, Tableau.DataExtension,
    enabled: true,
    dir: "_facts"
  ```

  ```yaml
  # _facts/homies.yaml
  - name: Mitch
  - name: Jimbo
  - name: Bobby
  ```

  ```heex
  <ul>
    <li :for={homie <- @data["homies"]}>
      <%= homie.name %>
    </li>
  </ul>
  ```

  """
  use Tableau.Extension, key: :data, type: :pre_build, priority: 200

  def run(token) do
    data =
      for file <- Path.wildcard(Path.join(token.data.dir, "**/*.{yml,yaml,exs}")), into: %{} do
        case Path.extname(file) do
          ".exs" ->
            key = Path.basename(file, ".exs")

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
