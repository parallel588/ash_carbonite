defmodule AshCarbonite.TestRepo.Migrations.InitCarbonite do
  use Ecto.Migration

  def up do
    Carbonite.Migrations.up(1..12)
  end

  def down do
    Carbonite.Migrations.down(12..1)
  end
end
