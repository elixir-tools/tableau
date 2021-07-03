defmodule TabDemo.Layouts.WithHeader do
  use Tableau.Layout

  layout Tableau.Layout.default()

  render do
    header class: "px-2 py-4 border border-red-500 w-full flex justify-between" do
      section do
        a class: "text-blue-500 hover:underline", href: "/" do
          "Home"
        end
      end

      section do
        "Log out"
      end
    end

    slot :default
  end
end
