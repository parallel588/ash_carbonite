defmodule AshCarbonite.MigrationGeneratorTest do
  use AshCarbonite.RepoCase, async: false

  alias AshCarbonite.MigrationGenerator

  setup do
    tmp_dir = Path.join([File.cwd!(), "_build", "test", "migrations_test_temp"])
    File.mkdir_p!(tmp_dir)

    on_exit(fn ->
      File.rm_rf!(tmp_dir)
    end)

    opts = [
      snapshot_path: Path.join([tmp_dir, "snapshots"]),
      migrations_path: Path.join([tmp_dir, "migrations"])
    ]

    Application.put_env(:ash_carbonite, AshCarbonite.TestRepo,
      snapshots_path: Path.join([tmp_dir, "snapshots"]),
      migrations_path: Path.join([tmp_dir, "migrations"])
    )

    {:ok, opts: opts}
  end

  test "generates migrations and snapshots", %{opts: opts} do
    defmodule Post1 do
      use Ash.Resource, data_layer: AshPostgres.DataLayer, extensions: [AshCarbonite.Resource]

      carbonite do
      end

      postgres do
        table("posts")
        repo(AshCarbonite.TestRepo)
      end

      attributes do
        uuid_primary_key(:id)
      end
    end

    defmodule Domain1 do
      use Ash.Domain

      resources do
        resource(Post1)
      end
    end

    # First run, creates migration and snapshot
    MigrationGenerator.generate([Domain1], opts)

    migrations_dir = opts[:migrations_path]
    snapshot_dir = opts[:snapshot_path]

    assert [migration] = File.ls!(migrations_dir)
    assert String.ends_with?(migration, "_add_carbonite_trigger_posts.exs")

    assert ["carbonite.json"] = File.ls!(snapshot_dir)

    # Second run, no changes
    MigrationGenerator.generate([Domain1], opts)
    assert [^migration] = File.ls!(migrations_dir)

    # Add a new resource
    defmodule Comment2 do
      use Ash.Resource, data_layer: AshPostgres.DataLayer, extensions: [AshCarbonite.Resource]

      carbonite do
      end

      postgres do
        table("comments")
        repo(AshCarbonite.TestRepo)
      end

      attributes do
        uuid_primary_key(:id)
      end
    end

    defmodule Domain2 do
      use Ash.Domain

      resources do
        resource(Post1)
        resource(Comment2)
      end
    end

    MigrationGenerator.generate([Domain2], opts)
    assert length(File.ls!(migrations_dir)) == 2
    assert [_add_posts, add_comments] = Enum.sort(File.ls!(migrations_dir))
    assert String.ends_with?(add_comments, "_add_carbonite_trigger_comments.exs")

    # Update a resource
    defmodule Post3 do
      use Ash.Resource, data_layer: AshPostgres.DataLayer, extensions: [AshCarbonite.Resource]

      carbonite do
        store_changed_from(true)
      end

      postgres do
        table("posts")
        repo(AshCarbonite.TestRepo)
      end

      attributes do
        uuid_primary_key(:id)
      end
    end

    defmodule Domain3 do
      use Ash.Domain

      resources do
        resource(Post3)
        resource(Comment2)
      end
    end

    MigrationGenerator.generate([Domain3], opts)
    assert length(File.ls!(migrations_dir)) == 3
    assert [_add_posts, _add_comments, update_posts] = Enum.sort(File.ls!(migrations_dir))
    assert String.ends_with?(update_posts, "_update_carbonite_trigger_posts.exs")

    # Remove a resource
    defmodule Domain4 do
      use Ash.Domain

      resources do
        resource(Post3)
      end
    end

    MigrationGenerator.generate([Domain4], opts)
    assert length(File.ls!(migrations_dir)) == 4

    assert [_add_posts, _add_comments, _update_posts, drop_comments] =
             Enum.sort(File.ls!(migrations_dir))

    assert String.ends_with?(drop_comments, "_drop_carbonite_trigger_comments.exs")
  end
end
