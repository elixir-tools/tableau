defmodule Tableau.Support.Helpers do
  @moduledoc false
  def post(idx, overrides) do
    base = %{
      title: "Post #{idx}",
      permalink: "/posts/post-#{1}",
      date: DateTime.utc_now(),
      body: """
      ## Welcome to Post #{idx}

      Here, we post like crazy.
      """
    }

    Map.merge(base, Map.new(overrides))
  end

  def page_with_permalink?(page, permalink) do
    is_struct(page, Tableau.Page) and page.permalink == permalink
  end
end
