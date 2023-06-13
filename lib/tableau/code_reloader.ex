defmodule Tableau.CodeReloader do
  @moduledoc false

  # Handles automatic code reloading.

  # Taken from [Still](https://github.com/still-ex/still/blob/277f4b546f0abf1ba56167a7ae894a49069b3c6c/lib/still/web/code_reloader.ex), which is taken from [Phoenix](https://github.com/phoenixframework/phoenix/blob/431c51e20d8840fa1f851160b659f78c6bb484c6/lib/phoenix/code_reloader/server.ex).
  use GenServer

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Reloads the code.
  """
  def reload do
    GenServer.call(__MODULE__, :reload)
  end

  def init(_opts) do
    {:ok, :nostate}
  end

  def handle_call(:reload, from, state) do
    froms = all_waiting([from])
    mix_compile(Code.ensure_loaded(Mix.Task))
    Enum.each(froms, &GenServer.reply(&1, :ok))

    {:noreply, state}
  end

  defp all_waiting(acc) do
    receive do
      {:"$gen_call", from, :reload} -> all_waiting([from | acc])
    after
      0 -> acc
    end
  end

  defp mix_compile({:error, _reason}) do
    Logger.error("Could not find Mix")
  end

  defp mix_compile({:module, Mix.Task}) do
    Mix.Task.reenable("compile.elixir")
    Mix.Task.run("compile.elixir")
  end
end
