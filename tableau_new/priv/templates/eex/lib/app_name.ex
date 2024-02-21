defmodule <%= @app_module %> do
  defmacro sigil_H({:<<>>, opts, [bin]}, _mods) do
    quote do
      _ = var!(assigns)
      unquote(EEx.compile_string(bin, opts))
    end
  end
end
