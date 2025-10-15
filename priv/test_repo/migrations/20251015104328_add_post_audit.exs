defmodule AshCarbonite.TestRepo.Migrations.AddPostAudit do
  use Ecto.Migration

  def up do
    Carbonite.Migrations.create_trigger(:posts)
  end

  def down do
    Carbonite.Migrations.drop_trigger(:posts)
  end
end
