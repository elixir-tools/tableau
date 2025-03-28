defmodule Tableau.MDExConverter do
  @moduledoc """
  Converter to parse markdown content with `MDEx`
  """
  def convert(_filepath, _front_matter, body, %{site: %{config: config}}) do
    MDEx.to_html!(body, config.markdown[:mdex])
  end
end
