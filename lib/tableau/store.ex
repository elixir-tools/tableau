defmodule Tableau.Store do
  use GenServer

  require Logger

  def start_link(opts) do
    GenServer.start_link(
      __MODULE__,
      Keyword.merge([base_post_path: Path.expand("_posts/")], opts),
      Keyword.take(opts, [:name])
    )
  end

  @impl GenServer
  def init(opts) do
    :ets.new(:store, [:set, :named_table, :public, read_concurrency: true])

    Tableau.Page.build(fn page ->
      :ets.insert(:store, {{:page, page.permalink, page.module.file_path}, {page, true}})
    end)

    Tableau.Post.build(opts[:base_post_path], fn post ->
      :ets.insert(:store, {{:post, post.permalink, post.path}, {post, true}})
    end)

    {:ok, %{}}
  end

  def all do
    :ets.tab2list(:store)
    |> Enum.map(fn {_, {page, _}} -> page end)
  end

  def fetch(permalink) do
    :ets.select(:store, [{{{:"$1", :"$2", :"$3"}, :"$4"}, [{:==, :"$2", permalink}], [:"$4"]}])
  end

  def mark_stale(file_path, server \\ __MODULE__) do
    GenServer.call(server, {:mark_stale, file_path})
  end

  def build(permalink, server \\ __MODULE__) do
    GenServer.call(server, {:build, permalink})
  end

  def posts() do
    :ets.select(:store, [{{{:post, :_, :_}, {:"$1", :_}}, [], [:"$1"]}])
  end

  @impl GenServer
  def handle_call({:mark_stale, file_path}, _from, state) do
    :ets.select_replace(:store, [
      {{{:"$1", :"$2", :"$3"}, {:"$4", :_}}, [{:==, :"$3", file_path}],
       [{{{{:"$1", :"$2", :"$3"}}, {{:"$4", true}}}}]}
    ])

    {:reply, :ok, state}
  end

  def handle_call({:build, permalink}, _from, state) do
    result =
      :ets.select(:store, [{{{:"$1", :"$2", :"$3"}, :"$4"}, [{:==, :"$2", permalink}], [:"$4"]}])

    case result do
      [{page, true}] ->
        page = Tableau.Renderable.refresh(page)

        :ets.select_replace(:store, [
          {{{:"$1", :"$2", :"$3"}, {:"$4", :_}}, [{:==, :"$2", permalink}],
           [{{{{:"$1", :"$2", :"$3"}}, {{page, false}}}}]}
        ])

        {time, _} =
          :timer.tc(fn ->
            Tableau.Renderable.render(page)
          end)

        Logger.debug("Built in: #{time / 1000}ms")

        {:reply, page, state}

      _ ->
        {:reply, :not_found, state}
    end
  end
end
