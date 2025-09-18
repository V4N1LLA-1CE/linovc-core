defmodule VenliCoreWeb.AuthController do
  use VenliCoreWeb, :controller

  action_fallback VenliCoreWeb.FallbackController

  alias VenliCore.Auth.Permissions
  alias VenliCore.Accounts
  alias VenliCore.Accounts.Guardian
  alias VenliCore.Auth.TokenGenerator

  def register(conn, %{
        "user" => %{"email" => email, "password" => password}
      }) do
    user_data = %{
      email: email,
      password: password,
      scopes: [Permissions.default_scope()]
    }

    case(Accounts.create_user(user_data)) do
      {:ok, user} ->
        token_pair = TokenGenerator.generate_token_pair(user)

        conn
        |> put_status(:created)
        |> json(%{
          message: "user created successfully",
          token: token_pair
        })

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def register(_conn, _params), do: {:error, :"register request failed"}

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        token_pair = TokenGenerator.generate_token_pair(user)

        json(conn, %{
          message: "login successful",
          token: token_pair
        })

      {:error, :invalid_credentials} ->
        {:error, :unauthorized}
    end
  end

  def login(_conn, _params), do: {:error, :"login request failed"}

  def refresh(conn, %{"refresh" => refresh_token}) do
    case Guardian.decode_and_verify(refresh_token) do
      {:ok, %{"sub" => user_id, "typ" => "refresh"}} ->
        user = Accounts.get_user!(user_id)
        token_pair = TokenGenerator.generate_token_pair(user)

        json(conn, %{
          message: "access token refreshed successfully",
          access_token: token_pair.access
        })

      {:ok, %{"typ" => _other_type}} ->
        {:error, :"invalid token type"}

      {:ok, _claims_without_typ} ->
        {:error, :"invalid token type"}

      {:error, _reason} ->
        {:error, :invalid_token}
    end
  end

  def refresh(_conn, _params), do: {:error, :bad_request}
end
