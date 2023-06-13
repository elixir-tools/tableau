defmodule Tableau.Graph.Node do
  @moduledoc false

  def type(module) do
    if function_exported?(module, :__tableau_type__, 0) do
      {:ok, module.__tableau_type__()}
    else
      :error
    end
  end

  def parent(module) do
    with {:ok, _} <- type(module) do
      if function_exported?(module, :__tableau_parent__, 0) do
        {:ok, module.__tableau_parent__()}
      else
        {:ok, :root}
      end
    end
  end
end
