defmodule AshCarbonite.RepoCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      alias AshCarbonite.TestRepo

      import Ecto
      import Ecto.Query
      import AshCarbonite.RepoCase

      # and any other stuff
    end
  end

  setup tags do
    :ok = Sandbox.checkout(AshCarbonite.TestRepo)

    if !tags[:async] do
      Sandbox.mode(AshCarbonite.TestRepo, {:shared, self()})
    end

    :ok
  end
end
