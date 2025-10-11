defmodule Mix.Tasks.AshCarbonite.GenerateMigrations do
  use Mix.Task

  @shortdoc "Generates migrations, and stores a snapshot of your resources"
  def run(args) do
    {name, args} =
      case args do
        ["-" <> _ | _] ->
          {nil, args}

        [first | rest] ->
          {first, rest}

        [] ->
          {nil, []}
      end

    {opts, _} =
      OptionParser.parse!(args,
        strict: [
          domains: :string,
          snapshot_path: :string,
          migration_path: :string,
          tenant_migration_path: :string,
          quiet: :boolean,
          snapshots_only: :boolean,
          auto_name: :boolean,
          name: :string,
          no_format: :boolean,
          dry_run: :boolean,
          check: :boolean,
          dev: :boolean,
          dont_drop_columns: :boolean,
          concurrent_indexes: :boolean
        ]
      )

    domains = AshCarbonite.Mix.Helpers.domains!(opts, args)

    opts =
      opts
      |> Keyword.put(:format, !opts[:no_format])
      |> Keyword.delete(:no_format)
      |> Keyword.put_new(:name, name)

    AshCarbonite.MigrationGenerator.generate(domains, opts)
  end
end
