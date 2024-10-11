defmodule Tableau.DataExtension do
  @moduledoc """
  YAML files and Elixir scripts (.exs) in the configured directory will be automatically parsed/executed and made available in an `@data` assign in your templates.

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

  <!-- tabs-open -->

  ### YAML

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

  ### Elixir

  ```elixir
  # _facts/homies.exs
  resp = Req.get!("https://example.com/homies")

  resp.body["homies"]
  ```

  ```heex
  <ul>
    <li :for={homie <- @data["homies"]}>
      <%= homie.name %>
    </li>
  </ul>
  ```

  <!-- tabs-close -->
  """
  use Tableau.Extension, key: :data, type: :pre_build, priority: 200

  import Schematic

  def config(config) do
    unify(
      map(%{
        optional(:enabled, true) => bool(),
        optional(:dir, "_data") => str()
      }),
      config
    )
  end

  def run(token) do
    data =
      for file <- Path.wildcard(Path.join(token.extensions.data.config.dir, "**/*.{yml,yaml,exs}")), into: %{} do
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
