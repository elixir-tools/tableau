defmodule Tableau.Layouts.App do
  use Tableau.Layout

  render do
    div do
      slot :default
    end
  end
end
