defmodule Tableau.Render do
  require Temple.Component

  def recursively_render([page], site) when is_atom(page) do
    Temple.Component.__component__(page, site)
  end

  def recursively_render([page], _site) when is_binary(page) do
    Phoenix.HTML.raw(page)
  end

  def recursively_render([mod | rest], site) do
    Temple.Component.__component__ mod, site do
      {:default, _} ->
        recursively_render(rest, site)
    end
  end

  def gather_modules(:root, modules) do
    modules
  end

  def gather_modules(mod, modules) do
    gather_modules(mod.layout(), [mod | modules])
  end
end
