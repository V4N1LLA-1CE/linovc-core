defmodule LinovcCore.UserManager.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :password, :string
    field :name, :string
    field :headline, :string
    field :bio, :string
    field :location, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :name, :headline, :bio, :location])
    |> validate_required([:email, :password])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email")
    |> validate_length(:password, min: 8, message: "must be at least 8 characters")
    |> validate_length(:name, max: 255, message: "cannot exceed 255 characters")
    |> validate_length(:headline, max: 255, message: "cannot exceed 255 characters")
    |> validate_length(:bio, max: 1000, message: "cannot exceed 1000 characters")
    |> validate_length(:location, max: 255, message: "cannot exceed 255 characters")
    |> unique_constraint(:email)
    |> hash_password()
  end

  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password: Argon2.hash_pwd_salt(password))
  end

  defp hash_password(changeset), do: changeset
end
