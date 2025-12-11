defmodule Tableau.Extension.Common do
  @moduledoc false

  @doc """
  Expand content paths from a wildcard.
  """
  def paths(wildcard) do
    wildcard |> Path.wildcard() |> Enum.sort()
  end

  @doc """
  Transform strings from any language into slugs using `Slug.slugify/1`.

  Returns the original string if the slug cannot be generated.
  """
  def slugify(string, overrides \\ [])

  def slugify(string, %{site: %{config: config}}) do
    Slug.slugify(string, config.slug) || string
  end

  def slugify(string, config) when is_map(config) do
    slugify(string)
  end

  def slugify(string, overrides) do
    {:ok, config} = Tableau.Config.get()

    Slug.slugify(string, Keyword.merge(config.slug, overrides)) || string
  end

  @doc """
  Build content entries from a list of paths.

  Content should contain YAML frontmatter, with the body from the file passed to the callback.
  """
  def entries(paths, callback) do
    for path <- paths do
      {front_matter, body} = Tableau.YamlFrontMatter.parse!(File.read!(path), atoms: true)
      "." <> ext = Path.extname(path)
      callback.(%{path: path, ext: String.to_atom(ext), front_matter: front_matter, pre_convert_body: body})
    end
  end

  @doc """
  Builds a permalink from a template and frontmatter and/or config.

  Frontmatter keys are substituted for colon prefixed template keys of the same name.

  If no permalink template is provided, the permalink will be derived from the file path.

  If the frontamtter contains a `:date` key, it is broken down into `:day`, `:month`, and `:year`
  components and those can be used in the permalink template.
  """
  def build_permalink(%{permalink: permalink} = front_matter, _config) do
    permalink
    |> transform_permalink(front_matter)
    |> then(&Map.put(front_matter, :permalink, &1))
  end

  def build_permalink(front_matter, %{permalink: permalink}) when not is_nil(permalink) do
    permalink
    |> transform_permalink(front_matter)
    |> then(&Map.put(front_matter, :permalink, &1))
  end

  def build_permalink(%{file: filename} = front_matter, config) do
    filename
    |> Path.rootname()
    |> then(fn rootname ->
      for dir <- List.wrap(config.dir), reduce: rootname do
        rootname ->
          String.replace_prefix(rootname, dir, "")
      end
    end)
    |> transform_permalink(front_matter)
    |> then(&Map.put(front_matter, :permalink, &1))
  end

  defp transform_permalink(path, front_matter) do
    vars =
      front_matter
      |> Map.new(fn {k, v} -> {":#{k}", v} end)
      |> then(fn vars ->
        if is_struct(front_matter[:date], DateTime) do
          Map.merge(vars, %{
            ":day" => front_matter.date.day |> to_string() |> String.pad_leading(2, "0"),
            ":month" => front_matter.date.month |> to_string() |> String.pad_leading(2, "0"),
            ":year" => front_matter.date.year
          })
        else
          vars
        end
      end)

    String.replace(path, Map.keys(vars), fn key ->
      vars |> Map.fetch!(key) |> to_string() |> Slug.slugify(ignore: ["."])
    end)
  end
end
