defmodule Tableau.Store do
  use GenServer

  require Logger

  @cache :tableau_store_cache

  def start_link(opts) do
    GenServer.start_link(
      __MODULE__,
      Keyword.merge([base_post_path: Path.expand("_posts/")], opts),
      Keyword.take(opts, [:name])
    )
  end

  @impl GenServer
  def init(opts) do
    Mentat.start_link(name: @cache)

    Tableau.Post.build(opts[:base_post_path], fn post ->
      content = Tableau.Renderable.render(post)
      Mentat.put(@cache, post.permalink, {post, content})

      Tableau.Renderable.write!(post, content)
    end)

    Tableau.Page.build(fn page ->
      content = Tableau.Renderable.render(page)
      Mentat.put(@cache, page.permalink, {page, content})

      Tableau.Renderable.write!(page, content)
    end)

    {:ok, %{opts: opts}}
  end

  def all do
    Mentat.keys(@cache)
    |> Enum.map(fn k ->
      {page, _} = Mentat.get(@cache, k)
      page
    end)
  end

  def fetch(permalink) do
    Mentat.get(@cache, permalink)
  end

  def build(permalink, server \\ __MODULE__) do
    GenServer.call(server, {:build, permalink})
  end

  def posts() do
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

  @impl true
  def handle_call({:build, permalink}, _from, state) do
    {time, {resp, built?}} =
      :timer.tc(fn ->
        # rebuild and write all posts
        Tableau.Post.build(state.opts[:base_post_path], fn post ->
          Mentat.fetch(@cache, post.permalink, fn _key ->
            content = Tableau.Renderable.render(post)
            Tableau.Renderable.write!(post, content)
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
                  Tableau.Renderable.write!(post, content)

                  post
                end
              end)

            pages =
              Tableau.Page.build(fn page ->
                if page.permalink == key do
                  page = Tableau.Renderable.refresh(page)
                  content = Tableau.Renderable.render(page)
                  Tableau.Renderable.write!(page, content)
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
                Tableau.Renderable.write!(refreshed_page, new_content)

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
