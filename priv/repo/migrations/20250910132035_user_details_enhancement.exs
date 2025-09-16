defmodule VenliCore.Repo.Migrations.UserDetailsEnhancement do
  use Ecto.Migration

  def change do
    alter(table(:users)) do
      add :name, :text
      add :headline, :text
      add :bio, :text
      add :location, :text
    end
  end
end
