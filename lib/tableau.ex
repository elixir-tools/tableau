defmodule Tableau do
  @moduledoc """
  Documentation for `Tableau`.
  """

  def module_prefix() do
    Mix.Project.config()
    |> Keyword.fetch!(:app)
    |> to_string()
    |> Macro.camelize()
    |> List.wrap()
    |> Module.concat()
  end
end
