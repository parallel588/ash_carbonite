defmodule AshCarbonite.Test.PostUpdated do
  use Ash.Resource,
    domain: AshCarbonite.Test.Domain,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshCarbonite.Resource]

  carbonite do
    store_changed_from(true)
  end

  postgres do
    table("posts")
    repo(AshCarbonite.TestRepo)
  end

  attributes do
    uuid_primary_key(:id)
    attribute(:title, :string)
  end
end
