defmodule Tableau.PageExtension.Pages.Page do
  @moduledoc false
  def build(filename, attrs, body) do
    {:ok, page_config} =
      Tableau.PageExtension.Config.new(Map.new(Application.get_env(:tableau, Tableau.PageExtension, %{})))

    attrs
    |> Map.put(:__tableau_page_extension__, true)
    |> Map.put(:body, body)
    |> Map.put(:file, filename)
    |> Map.put(:layout, Module.concat([attrs.layout || page_config.layout]))
    |> Map.put_new_lazy(:title, fn ->
      with {:ok, document} <- Floki.parse_fragment(body),
           [hd | _] <- Floki.find(document, "h1") do
        Floki.text(hd)
      else
        _ -> nil
      end
    end)
    |> build_permalink(page_config)
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

  defp build_permalink(%{file: filename} = attrs, config) do
    filename
    |> Path.rootname()
    |> String.replace_prefix(config.dir, "")
    |> transform_permalink(attrs)
    |> then(&Map.put(attrs, :permalink, &1))
  end

  defp transform_permalink(path, attrs) do
    vars = Map.new(attrs, fn {k, v} -> {":#{k}", v} end)

    path
    |> String.replace(Map.keys(vars), &to_string(Map.fetch!(vars, &1)))
    |> String.replace(" ", "-")
    |> String.replace("_", "-")
    |> String.replace(~r/[^[:alnum:]\/\-.]/, "")
    |> String.downcase()
  end
end
