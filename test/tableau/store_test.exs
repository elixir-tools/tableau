defmodule Tableau.StoreTest do
  use ExUnit.Case, async: true

  alias Tableau.Store

  setup do
    store =
      start_supervised!(
        {Tableau.Store, [base_post_path: Path.expand("../../example/_posts", __DIR__)]}
      )

    [store: store]
  end

  test "correctly sets stale state", %{store: store} do
    Store.build("/posts/hello-world!", store)
    assert [{_, {_, true}}, {_, {_, false}}] = :ets.tab2list(:store)

    Store.mark_stale(Path.expand("../../example/_posts/first-post.md", __DIR__), store)

    assert [{_, {_, true}}, {_, {_, true}}] = :ets.tab2list(:store)
  end
end
