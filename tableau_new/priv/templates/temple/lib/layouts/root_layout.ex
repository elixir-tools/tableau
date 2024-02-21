defmodule <%= @app_module %>.RootLayout do
  use <%= @app_module %>.Component
  use Tableau.Layout

  def template(assigns) do
    temple do
      "<!DOCTYPE html>"

      html lang: "en"  do
        head do
          meta charset: "utf-8"
          meta http_equiv: "X-UA-Compatible", content: "IE=edge"
          meta name: "viewport", content: "width=device-width, initial-scale=1.0"

          title do
            [@page[:title], <%= inspect(Macro.to_string(@app_module)) %>]
            |> Enum.filter(& &1)
            |> Enum.intersperse("|")
            |> Enum.join(" ")
          end

          link rel: "stylesheet", href: "/css/site.css"
        end

        body do
          main do
            render @inner_content
          end

          if Mix.env() == :dev do
            c &Tableau.live_reload/1
          end
        end
      end
    end
  end
end

