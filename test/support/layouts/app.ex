defmodule Tableau.Layouts.App do
  use Tableau.Layout

  require EEx

  EEx.function_from_string(
    :def,
    :render,
    """
    <div>
      <=% @inner_content %>
    </div>
    """,
    [:_assigns]
  )
end
