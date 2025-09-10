defmodule LinovcCore.Repo.Migrations.UserDetailsEnhancement do
  use Ecto.Migration

  def change do
    alter(table(:users)) do
      add :firstname, :text
      add :lastname, :text
      add :headline, :text
      add :bio, :text
      add :location, :text
    end
  end
end
