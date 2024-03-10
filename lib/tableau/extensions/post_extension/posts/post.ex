defmodule Tableau.PostExtension.Posts.Post do
  @moduledoc false
  def build(filename, attrs, body) do
    {:ok, post_config} =
      Tableau.PostExtension.Config.new(Map.new(Application.get_env(:tableau, Tableau.PostExtension, %{})))

    Application.put_env(:date_time_parser, :include_zones_from, ~N[2010-01-01T00:00:00])

    attrs
    |> Map.put(:__tableau_post_extension__, true)
    |> Map.put(:body, body)
    |> Map.put(:file, filename)
    |> Map.put(:layout, Module.concat([attrs[:layout] || post_config.layout]))
    |> Map.put_new_lazy(:title, fn ->
      with {:ok, document} <- Floki.parse_fragment(body),
           [hd | _] <- Floki.find(document, "h1") do
        Floki.text(hd)
      else
        _ -> nil
      end
    end)
    |> Map.put(:date, DateTimeParser.parse_datetime!(attrs.date, assume_time: true, assume_utc: true))
    |> build_permalink(post_config)
  end

  def parse(_file_path, content) do
    Tableau.YamlFrontMatter.parse!(content, atoms: true)
  end

  defp build_permalink(%{permalink: permalink} = attrs, _config) do
    permalink
    |> transform_permalink(attrs)
    |> then(&Map.put(attrs, :permalink, &1))
  end

  defp build_permalink(attrs, %{permalink: permalink}) when not is_nil(permalink) do
    permalink
    |> transform_permalink(attrs)
    |> then(&Map.put(attrs, :permalink, &1))
  end

  defp build_permalink(%{file: filename} = attrs, _) do
    filename
    |> Path.rootname()
    |> transform_permalink(attrs)
    |> then(&Map.put(attrs, :permalink, &1))
  end

  defp transform_permalink(path, attrs) do
    vars =
      attrs
      |> Map.new(fn {k, v} -> {":#{k}", v} end)
      |> Map.merge(%{
        ":day" => attrs.date.day |> to_string() |> String.pad_leading(2, "0"),
        ":month" => attrs.date.month |> to_string() |> String.pad_leading(2, "0"),
        ":year" => attrs.date.year
      })

    path
    |> String.replace(Map.keys(vars), &to_string(Map.fetch!(vars, &1)))
    |> String.replace(" ", "-")
    |> String.replace("_", "-")
    |> String.replace(~r/[^[:alnum:]\/\-.]/, "")
    |> String.downcase()
    |> URI.encode()
  end
end
