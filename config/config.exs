import Config

config :elixir, :time_zone_database, Tz.TimeZoneDatabase

config :tableau, :config, url: "http://localhost:4999", out_dir: "_site"

import_config "#{Mix.env()}.exs"
