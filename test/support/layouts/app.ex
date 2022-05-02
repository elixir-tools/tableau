defmodule Tableau.Layouts.App do
  use Tableau.Layout

  import Temple

  def render(assigns) do
    temple do
      div do
        slot :default
      end
    end
  end
end
