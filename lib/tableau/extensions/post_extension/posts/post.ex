defmodule Tableau.PostExtension.Posts.Post do
  @moduledoc false
  def build(filename, attrs, body) do
    {:ok, config} = Tableau.Config.new(Map.new(Application.get_env(:tableau, :config, %{})))

    {:ok, post_config} =
      Tableau.PostExtension.Config.new(Map.new(Application.get_env(:tableau, Tableau.PostExtension, %{})))

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
    |> Map.put(
      :date,
      DateTime.from_naive!(
        attrs.date |> Code.eval_string() |> elem(0),
        config.timezone
      )
    )
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
        ":day" => attrs.date.day,
        ":month" => attrs.date.month,
        ":year" => attrs.date.year
      })

    path
    |> String.replace(Map.keys(vars), &to_string(Map.fetch!(vars, &1)))
    |> String.replace(" ", "-")
    |> String.replace(~r/[^[:alnum:]\/\-]/, "")
    |> String.downcase()
  end
end
