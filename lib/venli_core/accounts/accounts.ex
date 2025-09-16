defmodule VenliCore.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias VenliCore.Repo
  alias Argon2

  alias VenliCore.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def authenticate_user(email, plain_text_password) do
    query = from u in User, where: u.email == ^email

    case Repo.one(query) do
      nil ->
        Argon2.no_user_verify()
        {:error, :invalid_credentials}

      user ->
        if Argon2.verify_pass(plain_text_password, user.password) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end

  @doc """
  Gets a user by email.
  """
  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Creates or updates a user from OAuth data with auto-linking by email.
  """
  def create_or_update_oauth_user(oauth_info, account_type) do
    email = oauth_info.info.email
    name = oauth_info.info.name

    case get_user_by_email(email) do
      nil ->
        # create new user
        create_user(%{
          email: email,
          name: name,
          password: generate_random_password(),
          scopes: [account_type]
        })

      existing_user ->
        # auto-link: update name if not set, ensure account type is included
        updated_scopes =
          if account_type in existing_user.scopes do
            existing_user.scopes
          else
            [account_type | existing_user.scopes]
          end

        update_attrs = %{scopes: updated_scopes}

        update_attrs =
          if is_nil(existing_user.name) or existing_user.name == "" do
            Map.put(update_attrs, :name, name)
          else
            update_attrs
          end

        update_user(existing_user, update_attrs)
    end
  end

  defp generate_random_password do
    :crypto.strong_rand_bytes(32) |> Base.encode64()
  end
end
