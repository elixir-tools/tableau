defmodule Tableau.Store do
  @moduledoc false
  use GenServer

  require Logger

  @cache :tableau_pages_cache
  @data_cache :tableau_data_cache

  def start_link(opts) do
    GenServer.start_link(
      __MODULE__,
      Keyword.merge([base_post_path: Path.expand("_posts/")], opts),
      Keyword.take(opts, [:name])
    )
  end

  @impl GenServer
  def init(opts) do
    page_cache = Keyword.get(opts, :page_cache, @cache)
    data_cache = Keyword.get(opts, :data_cache, @data_cache)

    Mentat.start_link(name: page_cache)
    Mentat.start_link(name: data_cache)

    Tableau.Data.build(fn %Tableau.Data{} = data ->
      data = Tableau.Data.fetch(data)
      Mentat.put(data_cache, data.name, data)
    end)

    Tableau.Post.build(opts[:base_post_path], fn post ->
      content = Tableau.Renderable.render(post)
      Mentat.put(page_cache, post.permalink, {post, content})

      Tableau.Renderable.write!(post, content, opts)
    end)

    Tableau.Page.build(fn page ->
      content = Tableau.Renderable.render(page)
      Mentat.put(page_cache, page.permalink, {page, content})

      Tableau.Renderable.write!(page, content, opts)
    end)

    {:ok, %{opts: opts, page_cache: page_cache, data_cache: data_cache}}
  end

  def all do
    Mentat.keys(@cache)
    |> Enum.map(fn k ->
      {page, _} = Mentat.get(@cache, k)
      page
    end)
  end

  def build(permalink, server \\ __MODULE__) do
    GenServer.call(server, {:build, permalink})
  end

  def posts do
    @cache
    |> Mentat.keys()
    |> Enum.map(fn k ->
      {p, _} = Mentat.get(@cache, k)
      p
    end)
    |> Enum.filter(fn p ->
      match?(%Tableau.Post{}, p)
    end)
  end

  def data do
    @data_cache
    |> Mentat.keys()
    |> Map.new(fn k ->
      data = Mentat.get(@data_cache, k)
      {k, data.data}
    end)
  end

  @impl true
  def handle_call({:build, permalink}, _from, state) do
    {time, {resp, built?}} =
      :timer.tc(fn ->
        # data should be fetched at compile time,
        # so we can thankfully just re-cache them all here
        Tableau.Data.build(fn %Tableau.Data{} = data ->
          data = Tableau.Data.fetch(data)
          Mentat.put(@data_cache, data.name, data)
        end)

        # rebuild and write all posts
        Tableau.Post.build(state.opts[:base_post_path], fn post ->
          Mentat.fetch(@cache, post.permalink, fn _key ->
            content = Tableau.Renderable.render(post)
            Tableau.Renderable.write!(post, content, state.opts)
            {:commit, {post, content}}
          end)
        end)

        # fetch the page for the current permalink
        # cache and write to disk if it it's a new page
        result =
          Mentat.fetch(@cache, permalink, fn key ->
            posts =
              Tableau.Post.build(state.opts[:base_post_path], fn post ->
                if post.permalink == key do
                  post = Tableau.Renderable.refresh(post)
                  content = Tableau.Renderable.render(post)
                  Tableau.Renderable.write!(post, content, state.opts)

                  post
                end
              end)

            pages =
              Tableau.Page.build(fn page ->
                if page.permalink == key do
                  page = Tableau.Renderable.refresh(page)
                  content = Tableau.Renderable.render(page)
                  Tableau.Renderable.write!(page, content, state.opts)
                  {page, content}
                end
              end)

            case Enum.filter(pages ++ posts, & &1) do
              [page] ->
                {:commit, page}

              _ ->
                {:ignore, nil}
            end
          end)

        case result do
          nil ->
            {{:reply, :not_found, state}, false}

          {page, old_content} ->
            # refresh the page struct and re-render
            refreshed_page = Tableau.Renderable.refresh(page)

            # we re-render, because data could have changed, even if the module content did not change
            new_content = Tableau.Renderable.render(refreshed_page)

            # if the content has changed, write to disk
            # and cache the results
            # we return true or false to determine whether to log the build time
            rebuilt =
              if old_content != new_content do
                Tableau.Renderable.write!(refreshed_page, new_content, state.opts)

                Mentat.put(@cache, refreshed_page.permalink, {refreshed_page, new_content})

                true
              else
                false
              end

            {{:reply, nil, state}, rebuilt}
        end
      end)

    if built? do
      Logger.debug("Built in: #{time / 1000}ms")
    end

    resp
  end
end
