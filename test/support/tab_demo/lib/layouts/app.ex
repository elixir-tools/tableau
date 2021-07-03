defmodule TabDemo.Layouts.App do
  use Tableau.Layout

  render do
    "<!DOCTYPE html>"

    html lang: "en" do
      head do
        meta(charset: "utf-8")
        meta(http_equiv: "X-UA-Compatible", content: "IE=edge")
        meta(name: "viewport", content: "width=device-width, initial-scale=1.0")

        link rel: "shortcut icon",
             href:
               "data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20viewBox%3D%220%200%20100%20100%22%3E%3Ctext%20y%3D%22.9em%22%20font-size%3D%2290%22%3E%E2%98%80%EF%B8%8F%3C%2Ftext%3E%3C%2Fsvg%3E",
             type: "image/svg+xml"

        script(src: "https://unpkg.com/tailwindcss-jit-cdn")
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

            slot :default
          end
        end
      end

      script defer: true do
        """
        function connect() {
          try {
            window.socket = new WebSocket('ws://' + location.host + '/ws');

            window.socket.onmessage = function(e) {
              if (e.data === "reload") {
                location.reload();
              }
            }

            window.socket.onopen = () => {
              waitForConnection(() => window.socket.send("subscribe"), 300);
            };

            window.socket.onclose = () => {
              setTimeout(() => connect(), 500);
            };

            function waitForConnection(callback, interval) {
              console.log("Waiting for connection!")
              if (window.socket.readyState === 1) {
                callback();
              } else {
                setTimeout(() => waitForConnection(callback, interval), interval);
              }
            }
          } catch (e) {
            setTimeout(() => connect(), 500);
          }
        }

        connect();
        """
      end
    end
  end
end
