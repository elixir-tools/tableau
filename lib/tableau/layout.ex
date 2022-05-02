defmodule Tableau.Layout do
  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      import Tableau.Layout, only: [layout: 1]

      def layout?, do: true

      def layout, do: :root

      defoverridable layout: 0
    end
  end

  defmacro layout(layout) do
    quote do
      def layout() do
        unquote(layout)
      end
    end
  end

  def default() do
    Module.concat(Tableau.module_prefix(), Layouts.App)
  end
end
