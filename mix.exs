defmodule Tableau.MixProject do
  use Mix.Project

  @source_url "https://github.com/elixir-tools/tableau"

  def project do
    [
      app: :tableau,
      description: "Static site generator for elixir",
      source_url: @source_url,
      version: "0.17.1",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :inets],
      mod: {TableauDevServer.Application, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bandit, "~> 1.0"},
      {:date_time_parser, "~> 1.2"},
      {:floki, "~> 0.34"},
      {:html_entities, "~> 0.5.2"},
      {:libgraph, "~> 0.16.0"},
      {:mdex, "~> 0.2.0"},
      {:plug_static_index_html, "~> 1.0"},
      {:schematic, "~> 0.4"},
      {:tz, "~> 0.28.1"},
      {:web_dev_utils, "~> 0.2"},
      {:websock_adapter, "~> 0.5"},
      {:xml_builder, "~> 2.1"},
      {:yaml_elixir, "~> 2.9"},

      # dev
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:styler, "~> 1.0", only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["Mitchell Hanberg"],
      licenses: ["MIT"],
      links: %{
        GitHub: @source_url,
        Sponsor: "https://github.com/sponsors/mhanberg"
      },
      files: ~w(lib LICENSE mix.exs README.md .formatter.exs)
    ]
  end

  defp docs do
    [
      main: "Tableau",
      groups_for_modules: [
        Site: [
          Tableau,
          Tableau.Layout,
          Tableau.Page,
          Tableau.Document.Helper
        ],
        Converters: [
          Tableau.Converter,
          Tableau.MDExConverter
        ],
        Extensions: [
          Tableau.Extension,
          Tableau.PostExtension,
          Tableau.PageExtension,
          Tableau.SitemapExtension,
          Tableau.RSSExtension,
          Tableau.DataExtension
        ]
      ]
    ]
  end
end
