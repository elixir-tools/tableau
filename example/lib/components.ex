defmodule TabDemo.Components do
  import Temple

  def li(assigns) do
    temple do
      li do
        slot :default
      end
    end
  end
end
