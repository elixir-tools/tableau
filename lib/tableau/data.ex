defmodule Tableau.Data do
  @moduledoc """
  Declare data for your site.
  """
  defstruct module: nil, data: [], name: nil

  defmacro __using__(opts) do
    quote do
      @before_compile unquote(__MODULE__)

      import Tableau.Data, only: [data: 2, yaml: 1]
      Module.register_attribute(__MODULE__, :data_base_dir, [])
      def tableau_data?, do: true

      Module.put_attribute(__MODULE__, :data_base_dir, unquote(opts)[:base_dir])

      def data, do: []

      defoverridable data: 0
    end
  end

  defmacro __before_compile__(%{module: mod}) do
    path_to_yaml = Module.get_attribute(mod, :yaml)
    base_dir = Module.get_attribute(mod, :data_base_dir, "_data")

    file_path = Path.join([base_dir, path_to_yaml <> ".yml"])

    data = YamlElixir.read_from_file!(file_path)

    quote do
      def data do
        {unquote(path_to_yaml), unquote(Macro.escape(data))}
      end
    end
  end

  @callback data() :: list() | map()
  @callback name() :: atom()

  defmacro data(name, do: block) do
    {result, _} = Code.eval_quoted(block, [], __CALLER__)

    quote do
      def data do
        {unquote(name), unquote(Macro.escape(result))}
      end
    end
  end

  defmacro yaml(filename) do
    quote do
      @yaml unquote(filename)
    end
  end

  def build(callback \\ nil) do
    for {mod, _, _} <- :code.all_available(), tableau_data?(mod) do
      mod =
        mod
        |> to_string()
        |> String.to_existing_atom()

      data = struct!(__MODULE__, module: mod)

      if callback do
        callback.(data)
      else
        fetch(data)
      end
    end
  end

  def fetch(%{module: module} = data) do
    {name, d} = module.data()
    struct!(data, data: d, name: name)
  end

  defp tableau_data?(mod) do
    mod = to_string(mod)

    with true <- String.starts_with?(mod, "Elixir."),
         mod <- Module.concat([mod]),
         true = Code.ensure_loaded?(mod),
         true <- function_exported?(mod, :tableau_data?, 0) do
      mod.tableau_data?()
    else
      _ ->
        false
    end
  end
end
