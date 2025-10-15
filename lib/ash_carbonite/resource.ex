defmodule AshCarbonite.Resource do
  @moduledoc """
  An extension for `Ash.Resource` that provides versioning capabilities using Carbonite.
  """

  @carbonite %Spark.Dsl.Section{
    name: :carbonite,
    describe: """
    A section for configuring how versioning is derived for the resource.
    """,
    entities: [],
    schema: [
      primary_key_columns: [
        type: {:or, [{:list, :string}, nil]},
        default: nil,
        doc:
          "A list of columns that make up the primary key of the versioned table. If not provided, it will be inferred from the resource's primary key."
      ],
      excluded_columns: [
        type: {:or, [{:list, :string}, nil]},
        default: nil,
        doc: "A list of columns to exclude from versioning. Changes to these columns will not create a new version."
      ],
      filtered_columns: [
        type: {:or, [{:list, :string}, nil]},
        default: nil,
        doc:
          "A list of columns to include in versioning. If provided, only changes to these columns will create a new version. Cannot be used with `excluded_columns`."
      ],
      store_changed_from: [
        type: {:or, [nil, :boolean]},
        default: nil,
        doc: "If `true`, the old value of the changed field will be stored in the version record. Defaults to `false`."
      ]
    ]
  }

  use Spark.Dsl.Extension,
    sections: [@carbonite],
    transformers: [
      AshCarbonite.Resource.Transformers.AuditOnChange
    ]

  def codegen(_args) do
    Mix.Task.reenable("ash_carbonite.generate_migrations")
    Mix.Task.run("ash_carbonite.generate_migrations")
  end
end
