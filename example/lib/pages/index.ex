defmodule TabDemo.Pages.Index do
  use Tableau.Page

  import Temple

  permalink "/"

  def render(_) do
    temple do
      div class: "border-[5px] border-cyan-500" do
        "Hello, world!! from temple"
      end
    end
  end
end
