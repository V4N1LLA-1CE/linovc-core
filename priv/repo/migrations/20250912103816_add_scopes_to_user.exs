defmodule LinovcCore.Repo.Migrations.AddScopesToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :scopes, {:array, :text}, null: false
    end
  end
end
