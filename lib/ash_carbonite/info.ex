defmodule AshCarbonite.Resource.Info do
  @moduledoc "Introspection helpers for `AshCarbonite.Resource`"

  @spec primary_key_columns(Spark.Dsl.t() | Ash.Resource.t()) :: list(String.t())
  def primary_key_columns(resource) do
    Spark.Dsl.Extension.get_opt(
      resource,
      [:carbonite],
      :primary_key_columns,
      {:list, :string},
      []
    )
  end

  @spec excluded_columns(Spark.Dsl.t() | Ash.Resource.t()) :: list(String.t())
  def excluded_columns(resource) do
    Spark.Dsl.Extension.get_opt(resource, [:carbonite], :excluded_columns, {:list, :string}, [])
  end

  @spec filtered_columns(Spark.Dsl.t() | Ash.Resource.t()) :: list(String.t())
  def filtered_columns(resource) do
    Spark.Dsl.Extension.get_opt(resource, [:carbonite], :filtered_columns, {:list, :string}, [])
  end

  @spec store_changed_from(Spark.Dsl.t() | Ash.Resource.t()) :: boolean
  def store_changed_from(resource) do
    Spark.Dsl.Extension.get_opt(resource, [:carbonite], :store_changed_from, :boolean, false)
  end

  @spec carbonite_prefix(Spark.Dsl.t() | Ash.Resource.t()) :: String.t()
  def carbonite_prefix(resource) do
    Spark.Dsl.Extension.get_opt(resource, [:carbonite], :carbonite_prefix, :string, "")
  end
end
