defmodule Tableau.Layout do
  defmacro __using__(opts) do
    opts = Keyword.validate!(opts, [:layout])

    page =
      quote do
        def __tableau_type__, do: :layout
      end

    parent =
      quote do
        def __tableau_parent__, do: unquote(opts[:layout] || :root)
      end

    [page, parent]
  end
end
