import Config

config :logger, level: :warning

config :tableau, Mix.Tasks.Tableau.FailExtension, enabled: true
config :tableau, Mix.Tasks.Tableau.LogExtension, enabled: true
config :tableau, Tableau.PostExtension, enabled: true
config :tableau, Tableau.RSSExtension, enabled: false
config :tableau, Tableau.SitemapExtension, enabled: false
config :tableau, Tableau.TagExtension, enabled: false
config :tableau, :config, url: "http://localhost:4999"
