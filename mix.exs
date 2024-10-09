defmodule Tableau.MixProject do
  use Mix.Project

  @source_url "https://github.com/elixir-tools/tableau"

  def project do
    [
      app: :tableau,
      description: "Static site generator for elixir",
      source_url: @source_url,
      version: "0.17.1",
      elixir: "~> 1.12",
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
      mod: {Tableau.Application, []}
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
      {:floki, floki_constraint()},
      {:html_entities, "~> 0.5.2"},
      {:libgraph, "~> 0.16.0"},
      {:mdex, "~> 0.1"},
      {:plug_static_index_html, "~> 1.0"},
      {:schematic, "~> 0.3.1"},
      {:tz, "~> 0.28.1"},
      {:web_dev_utils, "~> 0.1"},
      {:websock_adapter, "~> 0.5"},
      {:xml_builder, "~> 2.1"},
      {:yaml_elixir, "~> 2.9"},

      # dev
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:styler, "~> 0.9", only: :dev}
    ]
  end

  defp floki_constraint do
    if Version.compare(System.version(), "1.13.0") == :lt do
      "~> 0.34.0 or ~> 0.35.0"
    else
      "~> 0.34"
    end
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
        Extensions: [
          Tableau.Extension,
          Tableau.PostExtension,
          Tableau.RSSExtension,
          Tableau.DataExtension
        ]
      ]
    ]
  end
end
