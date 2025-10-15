ExUnit.start()

{:ok, _} = Application.ensure_all_started(:ash_carbonite)

AshCarbonite.TestRepo.start_link()

# Ecto.Migrator.run(AshCarbonite.TestRepo, "priv/test_repo/migrations", :up, log: false)

Ecto.Adapters.SQL.Sandbox.mode(AshCarbonite.TestRepo, :manual)

Process.flag(:trap_exit, true)
