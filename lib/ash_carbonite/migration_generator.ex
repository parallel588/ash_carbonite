defmodule AshCarbonite.MigrationGenerator do
  @moduledoc false

  def generate(domains, opts) do
    domains = List.wrap(domains)

    all_resources = Enum.uniq(Enum.flat_map(domains, &Ash.Domain.Info.resources/1))

    all_resources
    |> Enum.filter(fn resource ->
      Ash.DataLayer.data_layer(resource) == AshPostgres.DataLayer &&
        AshCarbonite.Resource in Ash.Resource.Info.extensions(resource)
    end)
    |> Enum.group_by(&AshPostgres.DataLayer.Info.repo(&1, :mutate))
    |> Enum.each(fn {repo, resources} ->
      _repo_name = repo |> Module.split() |> List.last() |> Macro.underscore()
      snapshot_dir = snapshot_path(opts, repo)
      migrations_path = AshPostgres.Mix.Helpers.migrations_path(opts, repo)

      File.mkdir_p!(snapshot_dir)
      File.mkdir_p!(migrations_path)

      snapshot_file = Path.join([snapshot_dir, "carbonite.json"])

      old_snapshot =
        if File.exists?(snapshot_file) do
          snapshot_file
          |> File.read!()
          |> Jason.decode!()
        else
          %{}
        end

      new_snapshot =
        resources
        |> Enum.map(fn resource ->
          {
            to_string(AshPostgres.DataLayer.Info.table(resource)),
            carbonite_opts(resource)
          }
        end)
        |> Map.new()

      tables_to_add = Map.keys(new_snapshot) -- Map.keys(old_snapshot)
      tables_to_remove = Map.keys(old_snapshot) -- Map.keys(new_snapshot)
      tables_to_check = Map.keys(new_snapshot) -- tables_to_add

      repo_migrations_path = migrations_path

      generate_create_migrations(repo, repo_migrations_path, tables_to_add, new_snapshot)
      generate_drop_migrations(repo, repo_migrations_path, tables_to_remove, old_snapshot)

      generate_update_migrations(
        repo,
        repo_migrations_path,
        tables_to_check,
        old_snapshot,
        new_snapshot
      )

      if new_snapshot != old_snapshot do
        File.mkdir_p!(snapshot_dir)
        File.write!(snapshot_file, Jason.encode!(new_snapshot, pretty: true))
      end
    end)
  end

  defp carbonite_opts(resource) do
    [
      {"primary_key_columns", AshCarbonite.Resource.Info.primary_key_columns(resource)},
      {"excluded_columns", AshCarbonite.Resource.Info.excluded_columns(resource)},
      {"filtered_columns", AshCarbonite.Resource.Info.filtered_columns(resource)},
      {"store_changed_from", AshCarbonite.Resource.Info.store_changed_from(resource)}
    ]
    |> Enum.reject(fn {_, value} -> is_nil(value) end)
    |> Map.new()
  end

  defp generate_create_migrations(repo, migrations_path, tables, snapshot) do
    Enum.each(tables, fn table ->
      opts = Map.to_list(snapshot[table])

      migration_file =
        Path.join([migrations_path, "#{timestamp()}_add_carbonite_trigger_#{table}.exs"])

      migration_content = """
      defmodule #{inspect(repo)}.Migrations.AddCarboniteTriggerFor#{Macro.camelize(table)} do
        use Ecto.Migration

        def up do
          Carbonite.Migrations.create_trigger(:#{table}, #{inspect(opts)})
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

  defp generate_drop_migrations(repo, migrations_path, tables, old_snapshot) do
    Enum.each(tables, fn table ->
      opts = Map.to_list(old_snapshot[table])

      migration_file =
        Path.join([migrations_path, "#{timestamp()}_drop_carbonite_trigger_#{table}.exs"])

      migration_content = """
      defmodule #{inspect(repo)}.Migrations.DropCarboniteTriggerFor#{Macro.camelize(table)} do
        use Ecto.Migration

        def up do
          Carbonite.Migrations.drop_trigger(:#{table})
        end

        def down do
          Carbonite.Migrations.create_trigger(:#{table}, #{inspect(opts)})
        end
      end
      """

      File.write!(migration_file, migration_content)
      IO.puts("✅ Created migration #{migration_file}")
    end)
  end

  defp generate_update_migrations(repo, migrations_path, tables, old_snapshot, new_snapshot) do
    Enum.each(tables, fn table ->
      old_opts = Map.to_list(old_snapshot[table])
      new_opts = Map.to_list(new_snapshot[table])

      if old_opts != new_opts do
        migration_file =
          Path.join([migrations_path, "#{timestamp()}_update_carbonite_trigger_#{table}.exs"])

        migration_content = """
        defmodule #{inspect(repo)}.Migrations.UpdateCarboniteTriggerFor#{Macro.camelize(table)} do
          use Ecto.Migration

          def up do
            Carbonite.Migrations.drop_trigger(:#{table})
            Carbonite.Migrations.create_trigger(:#{table}, #{inspect(new_opts)})
          end

          def down do
            Carbonite.Migrations.drop_trigger(:#{table})
            Carbonite.Migrations.create_trigger(:#{table}, #{inspect(old_opts)})
          end
        end
        """

        File.write!(migration_file, migration_content)
        IO.puts("✅ Created migration #{migration_file}")
      end
    end)
  end

  defp snapshot_path(opts, repo) do
    repo_name = repo |> Module.split() |> List.last() |> Macro.underscore()

    Keyword.get(opts, :snapshot_path) ||
      repo.config()[:snapshots_path] ||
      (
        app = Keyword.fetch!(repo.config(), :otp_app)

        Path.join([
          Mix.Project.deps_paths()[app] || File.cwd!(),
          "priv",
          "resource_snapshots",
          repo_name
        ])
      )
  end

  defp timestamp do
    :timer.sleep(1000)
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: <<?0, ?0 + i>>
  defp pad(i), do: to_string(i)
end
