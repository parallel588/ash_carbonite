import Config

if Mix.env() == :test do
  config :ash_carbonite, ecto_repos: [AshCarbonite.TestRepo]

  config :ash_carbonite, AshCarbonite.TestRepo,
    username: "postgres",
    database: "ash_carbonite_test",
    hostname: "localhost",
    pool: Ecto.Adapters.SQL.Sandbox

  config :ash_carbonite, ash_domains: [Ash.Test.Domain]

  # sobelow_skip ["Config.Secrets"]
  config :ash_carbonite, AshCarbonite.TestRepo, password: "postgres"

  config :logger, level: :warning

  config :ash_carbonite, ash_domains: [AshCarbonite.Test.Domain]
  config :ash, :validate_domain_config_inclusion?, false
end
