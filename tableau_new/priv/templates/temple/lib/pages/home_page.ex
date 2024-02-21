defmodule <%= @app_module %>.HomePage do
  use <%= @app_module %>.Component

  use Tableau.Page,
    layout: <%= @app_module %>.RootLayout,
    permalink: "/"

  def template(_assigns) do
    temple do
      p do
        "hello, world!"
      end
    end
  end
end
