defmodule AshCarbonite.Resource.Changes.Audit do
  @moduledoc "Creates a new version whenever a resource is created, deleted, or updated"
  use Ash.Resource.Change

  require Ash.Query
  require Logger

  @impl true
  def change(changeset, _, _) do
    Ash.Changeset.around_transaction(changeset, fn changeset, do_action ->
      resource = changeset.resource
      repo = AshPostgres.DataLayer.Info.repo(resource)
      action_name = changeset.action.name

      {:ok, res} =
        repo.transaction(fn ->
          {:ok, _} =
            Carbonite.insert_transaction(
              repo,
              %{meta: %{resource: to_string(resource), action: action_name}}
            )

          do_action.(changeset)
        end)

      res
    end)
  end
end
