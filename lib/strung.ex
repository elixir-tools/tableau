defmodule Strung do
  defmacro sigil_g({:<<>>, _, [bin]}, _mods) do
    bin
  end
end
