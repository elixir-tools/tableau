import Config

config :tableau, :reloader,
  patterns: [
    ~r"lib/.*.ex",
    ~r"(_posts|_pages)/.*.md",<%= if @assets == "tailwind" do %>
    ~r"assets/.*.(css|js)"<% else %>~r"extra/.*.(css|js)"<% end %>
  ]

config :web_dev_utils, :reload_log, true
# uncomment this if you use something like ngrok
# config :web_dev_utils, :reload_url, "'wss://' + location.host + '/ws'"

<%= if @template == "temple" do %>
config :temple,
  engine: EEx.SmartEngine,
  attributes: {Temple, :attributes}
<% end %>

<%= if @assets == "tailwind" do %>
config :tailwind,
  version: "3.3.5",
  default: [
    args: ~w(
    --config=assets/tailwind.config.js
    --input=assets/css/site.css
    --output=_site/css/site.css
    )
  ]

config :tableau, :assets, tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
<% end %>

config :tableau, :config,
  url: "http://localhost:4999",
  markdown: [
    mdex: [
      extension: [table: true, header_ids: "", tasklist: true, strikethrough: true],
      render: [unsafe_: true],
      features: [syntax_highlight_theme: "kanagawa"]
    ]
  ]

config :tableau, Tableau.PageExtension, enabled: true
config :tableau, Tableau.PostExtension, enabled: true, future: true
config :tableau, Tableau.DataExtension, enabled: true
config :tableau, Tableau.SitemapExtension, enabled: true

config :tableau, Tableau.RSSExtension,
  enabled: true,
  title: <%= inspect(to_string(@app)) %>,
  description: "My beautiful website"

config :elixir, :time_zone_database, Tz.TimeZoneDatabase

import_config "#{Mix.env()}.exs"

