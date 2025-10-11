defmodule AshCarbonite.MixProject do
  use Mix.Project

  @version "0.0.1"

  def project do
    [
      app: :ash_carbonite,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ash, "~> 3.6.0"},
      {:ash_postgres, "~> 2.0"},
      {:carbonite, "~> 0.16.0"},
      {:spark, "~> 2.2 and >= 2.2.10"},
      {:igniter, "~> 0.6.1", only: [:dev, :test]}
    ]
  end

  defp aliases do
    []
  end
end
