defmodule Tableau.Data do
  defstruct module: nil, data: [], name: nil

  defmacro __using__(_) do
    quote do
      import Tableau.Data, only: [name: 1, data: 1]
      def tableau_data?(), do: true

      def data(), do: []

      defoverridable data: 0
    end
  end

  @callback data() :: list() | map()
  @callback name() :: atom()

  defmacro name(name) do
    quote do
      def name() do
        unquote(name)
      end
    end
  end

  defmacro data(do: block) do
    {result, _} = Code.eval_quoted(block, [], __CALLER__)

    quote do
      def data() do
        unquote(Macro.escape(result))
      end
    end
  end

  def build(callback \\ nil) do
    for {mod, _, _} <- :code.all_available(), tableau_data?(mod) do
      mod =
        mod
        |> to_string()
        |> String.to_existing_atom()

      data = struct!(__MODULE__, module: mod, name: mod.name())

      if callback do
        callback.(data)
      else
        fetch(data)
      end
    end
  end

  def fetch(%{module: module} = data) do
    struct!(data, data: module.data())
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
