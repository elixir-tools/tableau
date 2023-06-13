defmodule TabDemo.MixProject do
  use Mix.Project

  def project do
    [
      app: :tab_demo,
      version: "0.1.0",
      elixir: "~> 1.12",
      compilers: [:temple] ++ Mix.compilers(),
      consolidate_protocols: Mix.env() not in [:test, :dev],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      preferred_cli_env: [build: :prod]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :tableau]
    ]
  end

  def aliases() do
    [
      build: ["tableau.build", "tailwind default --minify"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tableau, path: "../"},
      {:temple, "~> 0.12"},
      {:benchee, "~> 1.0"},
      {:tailwind, "~> 0.1", runtime: Mix.env() == :dev},
      {:req, "~> 0.3"},
      {:easyxml, "~> 0.1.0-dev", github: "wojtekmach/easyxml", branch: "main"}
    ]
  end
end
