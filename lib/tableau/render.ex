defmodule Tableau.Render do
  def recursively_render([page], site) when is_atom(page) do
    page.render(site)
  end

  def recursively_render([page], _site) when is_binary(page) do
    page
  end

  def recursively_render([mod | rest], site) do
    site =
      Map.put(Map.new(site), :__slots__, fn {:default, %{}} ->
        recursively_render(rest, site)
      end)

    mod.render(site)
  end

  def gather_modules(:root, modules) do
    modules
  end

  def gather_modules(mod, modules) do
    gather_modules(mod.layout(), [mod | modules])
  end
end
