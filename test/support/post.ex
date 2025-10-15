defmodule AshCarbonite.Test.Post do
  use Ash.Resource,
    domain: AshCarbonite.Test.Domain,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshCarbonite.Resource]

  carbonite do
    primary_key_columns([])
    excluded_columns([])
    filtered_columns([])
    store_changed_from(false)
  end

  attributes do
    uuid_primary_key(:id)

    attribute(:title, :string) do
      public?(true)
    end

    attribute(:content, :string) do
      public?(true)
    end

    timestamps()
  end

  actions do
    default_accept(:*)

    defaults([:read, :destroy, :update])

    create :create do
      accept([:title, :content])
    end
  end

  postgres do
    table("posts")
    repo(AshCarbonite.TestRepo)
  end
end
