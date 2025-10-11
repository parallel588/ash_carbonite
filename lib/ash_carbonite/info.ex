defmodule AshCarbonite.Resource.Info do
  @moduledoc "Introspection helpers for `AshCarbonite.Resource`"

  @spec primary_key_columns(Spark.Dsl.t() | Ash.Resource.t()) :: list(string())
  def primary_key_columns(resource) do
    Spark.Dsl.Extension.get_opt(resource, [:carbonite], :primary_key_columns, {:list, :string}, [])
  end

  @spec excluded_key_columns(Spark.Dsl.t() | Ash.Resource.t()) :: list(string())
  def excluded_key_columns(resource) do
    Spark.Dsl.Extension.get_opt(resource, [:carbonite], :excluded_key_columns, {:list, :string}, [])
  end

  @spec filtered_key_columns(Spark.Dsl.t() | Ash.Resource.t()) :: list(string())
  def filtered_key_columns(resource) do
    Spark.Dsl.Extension.get_opt(resource, [:carbonite], :filtered_key_columns, {:list, :string}, [])
  end

  @spec store_changed_from(Spark.Dsl.t() | Ash.Resource.t()) :: boolean
  def store_changed_from(resource) do
    Spark.Dsl.Extension.get_opt(resource, [:carbonite], :store_changed_from, :boolean, false)
  end
end
