import Config

config :tableau, :assets,
  npx: [
    "tailwindcss",
    "-o",
    "_site/css/site.css",
    env: [{"NODE_ENV", "production"}]
  ]
