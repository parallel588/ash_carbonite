defmodule AshCarbonite.Test.Comment do
  use Ash.Resource,
    domain: AshCarbonite.Test.Domain,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshCarbonite.Resource]

  postgres do
    table("comments")
    repo(AshCarbonite.TestRepo)
  end

  attributes do
    uuid_primary_key(:id)
  end
end
