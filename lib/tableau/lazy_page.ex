defmodule Tableau.LazyPage do
  @moduledoc false
  defstruct [:handler]

  def run(lazy_page, assigns) do
    lazy_page.handler.(assigns)
  end
end
