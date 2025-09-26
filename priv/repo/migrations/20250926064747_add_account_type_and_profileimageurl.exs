defmodule VenliCore.Repo.Migrations.AddAccountTypeAndProfileimageurl do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :account_type, :text
      add :pfp_url, :text
    end
  end
end
