defmodule VenliCoreWeb.AuthController do
  use VenliCoreWeb, :controller

  action_fallback VenliCoreWeb.FallbackController

  alias VenliCore.Auth.Permissions
  alias VenliCore.Accounts
  alias VenliCore.Accounts.Guardian
  alias VenliCore.Auth.TokenGenerator
  alias VenliCore.Auth.Cookies

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
        |> put_resp_cookie(Cookies.refresh_cookie_key(), token_pair.refresh, Cookies.refresh_cookie_opts())
        |> json(%{
          message: "user created successfully",
          access_token: token_pair.access
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

        conn
        |> put_resp_cookie(Cookies.refresh_cookie_key(), token_pair.refresh, Cookies.refresh_cookie_opts())
        |> put_status(:ok)
        |> json(%{
          message: "login successful",
          access_token: token_pair.access
        })

      {:error, :invalid_credentials} ->
        {:error, :unauthorized}
    end
  end

  def login(_conn, _params), do: {:error, :"login request failed"}

  def refresh(conn, _params) do
    case conn.req_cookies[Cookies.refresh_cookie_key()] do
      nil ->
        {:error, :unauthorized}

      refresh_token ->
        case Guardian.decode_and_verify(refresh_token) do
          {:ok, %{"sub" => user_id, "typ" => "refresh"}} ->
            user = Accounts.get_user!(user_id)
            token_pair = TokenGenerator.generate_token_pair(user)

            conn
            |> put_status(:ok)
            |> json(%{
              message: "access token refreshed successfully",
              access_token: token_pair.access
            })

          {:ok, %{"typ" => _other_type}} ->
            {:error, :invalid_token_type}

          {:ok, _claims_without_typ} ->
            {:error, :invalid_token_type}

          {:error, _reason} ->
            {:error, :invalid_token}
        end
    end
  end

  def logout(conn, _params) do
    conn
    |> delete_resp_cookie(Cookies.refresh_cookie_key(), Cookies.delete_refresh_cookie_opts())
    |> put_status(:ok)
    |> json(%{
      message: "logged out successfully"
    })
  end
end
