defmodule Tableau.Extension.Common do
  @moduledoc false

  def paths(wildcard) do
    wildcard |> Path.wildcard() |> Enum.sort()
  end

  def entries(paths, parser_module, builder, opts) do
    Enum.flat_map(paths, fn path ->
      parsed_contents = parse_contents!(path, File.read!(path), parser_module)
      build_entry(builder, path, parsed_contents, opts)
    end)
  end

  defp build_entry(builder, path, {_attrs, _body} = parsed_contents, opts) do
    build_entry(builder, path, [parsed_contents], opts)
  end

  defp build_entry(builder, path, parsed_contents, opts) when is_list(parsed_contents) do
    converter_module = Keyword.get(opts, :html_converter)

    Enum.map(parsed_contents, fn {attrs, body} ->
      body =
        case converter_module do
          module -> module.convert(path, body, attrs, opts)
        end

      builder.build(path, attrs, body)
    end)
  end

  defp parse_contents!(path, contents, parser_module) do
    parser_module.parse(path, contents)
  end
end
