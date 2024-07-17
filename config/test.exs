import Config

config :logger, level: :warning

config :tableau, :config, url: "http://localhost:4999"
config :tableau, Tableau.RSSExtension, enabled: false
config :tableau, Tableau.PostExtension, enabled: false
config :tableau, Tableau.SitemapExtension, enabled: false
config :tableau, Mix.Tasks.Tableau.LogExtension, enabled: true
config :tableau, Mix.Tasks.Tableau.FailExtension, enabled: true
