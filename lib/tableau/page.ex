defmodule Tableau.Page do
  defmacro __using__(opts) do
    opts = Keyword.validate!(opts, [:layout, :permalink])

    page =
      quote do
        def __tableau_type__, do: :page
      end

    parent =
      quote do
        def __tableau_parent__, do: unquote(opts[:layout])
      end

    permalink =
      quote do
        def __tableau_permalink__, do: unquote(opts[:permalink])
      end

    [page, parent, permalink]
  end
end
