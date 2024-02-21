defmodule <%= @app_module %>.Component do
  use Temple.Component

  defmacro __using__(_) do
    quote do
      import Temple
      import unquote(__MODULE__)
    end
  end
end

