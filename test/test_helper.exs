defmodule Tableau.TestHelpers do
  @moduledoc false
  import ExUnit.Callbacks

  def purge_on_exit(mods) do
    on_exit(fn ->
      for mod <- mods do
        :code.delete(mod)
        :code.purge(mod)
      end
    end)
  end
end

ExUnit.start()
