defmodule Tableau.Extension.Common do
  @moduledoc false

  def paths(wildcard) do
    wildcard |> Path.wildcard() |> Enum.sort()
  end

  def entries(paths, builder, opts) do
    for path <- paths do
      {front_matter, body} = Tableau.YamlFrontMatter.parse!(File.read!(path), atoms: true)
      "." <> ext = Path.extname(path)
      converter = opts[:converters][String.to_atom(ext)]
      body = converter.convert(path, body, front_matter, opts)

      builder.build(path, front_matter, body)
    end
  end
end
