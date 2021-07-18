import Config

config :tableau, :reloader, dirs: ["./lib/app.ex", "./lib/pages/", "./_posts", "./_site/css"]

config :tableau, :assets,
  npx: [
    "tailwindcss",
    "-o",
    "_site/css/site.css",
    "--watch",
  ]

import_config "#{Mix.env()}.exs"
