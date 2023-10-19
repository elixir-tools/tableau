defmodule Tableau.MixProject do
  use Mix.Project

  @source_url "https://github.com/elixir-tools/tableau"

  def project do
    [
      app: :tableau,
      description: "Static site generator for elixir",
      source_url: @source_url,
      version: "0.7.1",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps()
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
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:file_system, "~> 0.2"},
      {:libgraph, "~> 0.16.0"},
      {:plug_cowboy, "~> 2.0"},
      {:plug_static_index_html, "~> 1.0"},
      {:schematic, "~> 0.3.1"},
      {:nimble_publisher, "~> 1.0"},
      {:yaml_elixir, "~> 2.9"},
      {:makeup_elixir, ">= 0.0.0"},
      {:tz, "~> 0.26.2"},

      # {:yaml_front_matter, "~> 1.0"},
      # {:jason, "~> 1.4"},
      # {:req, "~> 0.3", only: :test},
      # {:bypass, "~> 2.0", only: :test},
      # {:earmark, "~> 1.4"},
      {:floki, "~> 0.34", only: :test}
    ]
  end

  defp package() do
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
end
