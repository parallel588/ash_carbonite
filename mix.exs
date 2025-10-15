defmodule AshCarbonite.MixProject do
  use Mix.Project

  @version "0.0.1"
  @source_url "https://github.com/parallel588/ash_carbonite"
  @homepage_url "https://github.com/parallel588/ash_carbonite"

  def project do
    [
      app: :ash_carbonite,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      aliases: aliases(),
      docs: docs(),
      package: package(),
      description: description(),
      source_url: @source_url,
      homepage_url: @homepage_url
    ]
  end

  defp description do
    "An integration between Ash and Carbonite."
  end

  defp package do
    [
      maintainers: [],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :ash_postgres]
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
      {:jason, "~> 1.2"},
      {:spark, "~> 2.2 and >= 2.2.10"},
      {:igniter, "~> 0.6.1", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      docs: "docs"
    ]
  end

  defp docs do
    [
      main: "AshCarbonite",
      logo: "logos/ash-logo-colored-wordmark.svg",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extra_section: "GUIDES",
      extras: [
        "documentation/tutorials/getting_started.md"
      ],
      groups_for_modules: [
        Resources: [
          AshCarbonite.Test.Resource,
          AshCarbonite.Test.Resource.Status
        ],
        "Test Helpers": [
          AshCarbonite.Test.Registry,
          AshCarbonite.Test.Repo,
          AshCarbonite.Test.Api
        ]
      ]
    ]
  end
end
