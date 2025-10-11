defmodule AshCarbonite.MigrationGenerator do
  def generate(domains, opts) do
    domains = List.wrap(domains)

    all_resources = Enum.uniq(Enum.flat_map(domains, &Ash.Domain.Info.resources/1))

    tables =
      all_resources
      |> Enum.filter(fn resource ->
        Ash.DataLayer.data_layer(resource) == AshPostgres.DataLayer &&
          AshCarbonite.Resource in Ash.Resource.Info.extensions(resource)
      end)
      |> Enum.map(fn resource ->
        repo = AshPostgres.DataLayer.Info.repo(resource, :mutate)

        {
          resource,
          repo,
          AshPostgres.DataLayer.Info.table(resource),
          AshPostgres.Mix.Helpers.migrations_path(opts, repo)
        }
      end)

    Enum.each(tables, fn {resource, repo, table, migrations_path} ->
      path = migrations_path
      {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
      timestamp = "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
      migration_file = Path.join(path, "#{timestamp}_carbonite_trigger_#{table}.exs")

      migration_content = """
      defmodule #{inspect(repo)}.Migrations.AddCarboniteTriggerFor#{Macro.camelize(to_string(table))} do
        use Ecto.Migration

        def up do
          Carbonite.Migrations.create_trigger(:#{table})
        end

        def down do
          Carbonite.Migrations.drop_trigger(:#{table})
        end
      end
      """

      File.write!(migration_file, migration_content)
      IO.puts("✅ Created migration #{migration_file}")
    end)
  end

  defp pad(i) when i < 10, do: <<?0, ?0 + i>>
  defp pad(i), do: to_string(i)
end
