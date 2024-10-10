defmodule Tableau.MDExConverter do
  @moduledoc """
  Converter to parse markdown content with `MDEx`
  """
  def convert(_filepath, _front_matter, body, _opts) do
    {:ok, config} = Tableau.Config.get()

    MDEx.to_html!(body, config.markdown[:mdex])
  end
end
