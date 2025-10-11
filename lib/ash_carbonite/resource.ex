defmodule AshCarbonite.Resource do
  @moduledoc false

  @carbonite %Spark.Dsl.Section{
    name: :carbonite,
    describe: """
    A section for configuring how versioning is derived for the resource.
    """,
    entities: [],
    schema: [
      primary_key_columns: [
        type: {:list, :string},
        default: [],
        doc: ""
      ],
      excluded_columns: [
        type: {:list, :string},
        default: [],
        doc: ""
      ],
      filtered_columns: [
        type: {:list, :string},
        default: [],
        doc: ""
      ],
      store_changed_from: [
        type: :boolean,
        default: false,
        doc: ""
      ]
    ]
  }

  use Spark.Dsl.Extension,
    sections: [@carbonite],
    transformers: [
      AshCarbonite.Resource.Transformers.AuditOnChange
    ]

  def codegen(args) do
    Mix.Task.reenable("ash_carbonite.generate_migrations")
    Mix.Task.run("ash_carbonite.generate_migrations")
  end
end
