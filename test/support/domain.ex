defmodule AshCarbonite.Test.Domain do
  use Ash.Domain

  resources do
    resource(AshCarbonite.Test.Post)
  end
end
