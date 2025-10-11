defmodule AshCarbonite.Resource.Transformers.AuditOnChange do
  @moduledoc false
  use Spark.Dsl.Transformer
  alias Spark.Dsl.Transformer

  def transform(dsl_state) do
    case Transformer.build_entity(Ash.Resource.Dsl, [:changes], :change, change: AshCarbonite.Resource.Changes.Audit) do
      {:ok, change} ->
        {:ok, Transformer.add_entity(dsl_state, [:changes], change, type: :prepend)}

      other ->
        other
    end
  end
end
