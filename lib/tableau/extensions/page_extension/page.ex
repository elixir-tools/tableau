defmodule Tableau.PageExtension.Page do
  @moduledoc false
  def build(filename, front_matter, body) do
    {:ok, page_config} =
      Tableau.PageExtension.Config.new(Map.new(Application.get_env(:tableau, Tableau.PageExtension, %{})))

    front_matter
    |> Map.put(:__tableau_page_extension__, true)
    |> Map.put(:body, body)
    |> Map.put(:file, filename)
    |> Map.put(:layout, Module.concat([front_matter.layout || page_config.layout]))
    |> build_permalink(page_config)
  end

  defp build_permalink(%{permalink: permalink} = front_matter, _config) do
    permalink
    |> transform_permalink(front_matter)
    |> then(&Map.put(front_matter, :permalink, &1))
  end

  defp build_permalink(front_matter, %{permalink: permalink}) when not is_nil(permalink) do
    permalink
    |> transform_permalink(front_matter)
    |> then(&Map.put(front_matter, :permalink, &1))
  end

  defp build_permalink(%{file: filename} = front_matter, config) do
    filename
    |> Path.rootname()
    |> String.replace_prefix(config.dir, "")
    |> transform_permalink(front_matter)
    |> then(&Map.put(front_matter, :permalink, &1))
  end

  defp transform_permalink(path, front_matter) do
    vars = Map.new(front_matter, fn {k, v} -> {":#{k}", v} end)

    path
    |> String.replace(Map.keys(vars), &to_string(Map.fetch!(vars, &1)))
    |> String.replace(" ", "-")
    |> String.replace("_", "-")
    |> String.replace(~r/[^[:alnum:]\/\-.]/, "")
    |> String.downcase()
  end
end
