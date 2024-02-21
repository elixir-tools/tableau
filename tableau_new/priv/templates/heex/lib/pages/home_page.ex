defmodule <%= @app_module %>.HomePage do
  use Tableau.Page,
    layout: <%= @app_module %>.RootLayout,
    permalink: "/"

  use Phoenix.Component

  def template(assigns) do
    ~H"""
    <p>
      hello, world!
    </p>
    """
  end
end
