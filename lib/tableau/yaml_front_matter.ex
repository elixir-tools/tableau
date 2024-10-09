# Copyright (c) 2017 Sebastian De Deyne sebastiandedeyne@gmail.com
# Vendored from github.com/sebastiandedeyne/yaml_front_matter

defmodule Tableau.YamlFrontMatter.Error do
  @moduledoc false
  defexception message: "Error parsing yaml front matter"
end

defmodule Tableau.YamlFrontMatter do
  @moduledoc false
  def parse(string, opts \\ []) do
    string
    |> split_string()
    |> process_parts(opts)
  end

  def parse!(string, opts \\ []) do
    case parse(string, opts) do
      {:ok, matter, body} -> {atomicize(matter), body}
      {:error, _} -> raise Tableau.YamlFrontMatter.Error
    end
  end

  defp split_string(string) do
    split_pattern = ~r/[\s\r\n]---[\s\r\n]/s

    string
    |> String.trim_leading()
    |> then(&("\n" <> &1))
    |> then(&Regex.split(split_pattern, &1, parts: 3))
  end

  defp process_parts([_, yaml, body], opts) do
    case parse_yaml(yaml, opts) do
      {:ok, yaml} -> {:ok, yaml, body}
      {:error, error} -> {:error, error}
    end
  end

  defp process_parts(_, _), do: {:error, :invalid_front_matter}

  defp parse_yaml(yaml, opts) do
    case YamlElixir.read_from_string(yaml, opts) do
      {:ok, parsed} -> {:ok, parsed}
      error -> error
    end
  end

  defp atomicize(map) when is_map(map) do
    Map.new(map, fn
      {k, v} when is_binary(k) -> {String.to_atom(k), atomicize(v)}
      other -> other
    end)
  end

  defp atomicize(list) when is_list(list) do
    Enum.map(list, &atomicize/1)
  end

  defp atomicize(other), do: other
end
