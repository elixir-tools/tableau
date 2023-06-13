defmodule Tableau.MixProject do
  use Mix.Project

  def project do
    [
      app: :tableau,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
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
      {:libgraph, "~> 0.16.0"},
      {:plug_cowboy, "~> 2.0"},
      {:plug_static_index_html, "~> 1.0"},
      {:file_system, "~> 0.2"},
      # {:yaml_front_matter, "~> 1.0"},
      # {:jason, "~> 1.4"},
      # {:toml, "~> 0.6.2"},
      # {:req, "~> 0.3", only: :test},
      # {:bypass, "~> 2.0", only: :test},
      # {:earmark, "~> 1.4"},
      {:floki, "~> 0.34", only: :test}
    ]
  end
end
