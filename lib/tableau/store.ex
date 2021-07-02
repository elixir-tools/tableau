defmodule Tableau.Store do
  use GenServer

  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  @impl GenServer
  def init(_) do
    posts = Tableau.Post.build()
    pages = Tableau.Page.build()

    {:ok, %{posts: posts, pages: pages}}
  end

  def fetch(store \\ __MODULE__) do
    GenServer.call(store, :fetch)
  end

  @impl GenServer
  def handle_call(:fetch, _, state) do
    {:reply, state, state}
  end
end
