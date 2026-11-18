# Copyright (c) 2017 Sebastian De Deyne sebastiandedeyne@gmail.com
# Vendored from github.com/sebastiandedeyne/yaml_front_matter

defmodule Tableau.YamlFrontMatter.Error do
  @moduledoc false
  defexception [:message]

  @impl true
  def exception(value) do
    %__MODULE__{message: "Error parsing yaml front matter: #{inspect(value)}"}
  end
end

defmodule Tableau.YamlFrontMatter do
  @moduledoc false
  def parse(string) do
    string
    |> split_string()
    |> process_parts()
  end

  def parse!(string) do
    case parse(string) do
      {:ok, matter, body} -> {matter, body}
      {:error, error} -> raise Tableau.YamlFrontMatter.Error, error
    end
  end

  defp split_string(string) do
    split_pattern = ~r/[\s\r\n]---[\s\r\n]?/s

    string
    |> String.trim_leading()
    |> then(&("\n" <> &1))
    |> then(&Regex.split(split_pattern, &1, parts: 3))
  end

  defp process_parts([_, yaml | rest]) do
    case parse_yaml(yaml) do
      {:ok, yaml} -> {:ok, atomize(yaml), List.first(rest, "")}
      {:error, error} -> {:error, error}
    end
  end

  defp process_parts(_), do: {:error, :invalid_front_matter}

  defp parse_yaml(yaml) do
    case YamlElixir.read_from_string(yaml) do
      {:ok, parsed} -> {:ok, parsed}
      error -> error
    end
  end

  defp atomize(map) when is_map(map) do
    Map.new(map, fn
      {k, v} when is_binary(k) -> {String.to_atom(k), atomize(v)}
      other -> other
    end)
  end

  defp atomize(list) when is_list(list) do
    Enum.map(list, &atomize/1)
  end

  defp atomize(other), do: other
end
