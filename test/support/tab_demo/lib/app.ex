defmodule TabDemo.App do
  import Temple.Component

  render do
    "<!DOCTYPE html>"

    html lang: "en" do
      head do
        meta(charset: "utf-8")
        meta(http_equiv: "X-UA-Compatible", content: "IE=edge")
        meta(name: "viewport", content: "width=device-width, initial-scale=1.0")

        script src: "https://unpkg.com/tailwindcss-jit-cdn"
      end

      body class: "font-sans" do
        main class: "container mx-auto px-2" do
          div class: "border-4 border-green-500" do
            a class: "text-blue-500 hover:underline", href: "/about" do
              "About"
            end

            a class: "text-blue-500 hover:underline", href: "/posts" do
              "Posts"
            end

            @inner_content
          end
        end
      end
    end
  end
end
