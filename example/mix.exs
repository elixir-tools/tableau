defmodule TabDemo.MixProject do
  use Mix.Project

  def project do
    [
      app: :tab_demo,
      version: "0.1.0",
      elixir: "~> 1.12",
      compilers: [:temple] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :tableau]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tableau, path: "../"},
      {:benchee, "~> 1.0"},
      {:tailwind, "~> 0.1", runtime: Mix.env() == :dev}
    ]
  end
end
