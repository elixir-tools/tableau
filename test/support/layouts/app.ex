defmodule Tableau.Layouts.App do
  use Tableau.Layout

  import Temple

  def render(assigns) do
    temple do
      html do
        body do
          slot :default
        end
      end
    end
  end
end
