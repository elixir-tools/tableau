defmodule Tableau.Extension.Common do
  @moduledoc false

  def paths(wildcard) do
    wildcard |> Path.wildcard() |> Enum.sort()
  end

  def entries(paths, callback) do
    for path <- paths do
      {front_matter, body} = Tableau.YamlFrontMatter.parse!(File.read!(path), atoms: true)
      "." <> ext = Path.extname(path)
      callback.(%{path: path, ext: String.to_atom(ext), front_matter: front_matter, pre_convert_body: body})
    end
  end
end
