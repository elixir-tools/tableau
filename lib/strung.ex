defmodule Tableau.Strung do
  @moduledoc false

  defmacro sigil_g({:<<>>, _, [bin]}, _mods) do
    bin
  end
end
