defmodule <%= @app_module %>.MixProject do
  use Mix.Project

  def project do
    [
      app: :<%= @app %>,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      compilers: <%= if @template == "temple" do %>[:temple] ++ <% end %>Mix.compilers(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tableau, "~> 0.15"}<%= if @assets == "tailwind" do %>,
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev}<% end %><%= if @template == "temple" do %>,
      {:temple, "~> 0.12"}<% end %><%= if @template == "heex" do %>,
      {:phoenix_live_view, "~> 0.20"}<% end %>

      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
