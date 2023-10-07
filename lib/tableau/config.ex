defmodule Tableau.Config do
  @moduledoc false

  import Schematic

  defstruct include_dir: "extra"

  def new(config) do
    unify(schematic(), config)
  end

  defp schematic do
    schema(__MODULE__, %{
      optional(:include_dir) => str()
    })
  end
end
