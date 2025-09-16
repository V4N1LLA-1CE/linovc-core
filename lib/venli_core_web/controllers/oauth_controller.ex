defmodule VenliCoreWeb.OAuthController do
  use VenliCoreWeb, :controller
  plug Ueberauth

  action_fallback VenliCoreWeb.FallbackController

  alias VenliCore.Accounts
  alias VenliCore.Auth.TokenGenerator

  def request(conn, params) do
    # store account_type in session for callback
    account_type = params["account_type"] || "vc:default"

    conn
    |> put_session(:oauth_account_type, account_type)
    # ueberauth will handle the redirect, but we need a fallback response
    |> json(%{message: "OAuth initialization failed"})
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    # get account_type from session
    account_type = get_session(conn, :oauth_account_type) || "vc:default"

    case Accounts.create_or_update_oauth_user(auth, account_type) do
      {:ok, user} ->
        token_pair = TokenGenerator.generate_token_pair(user)

        conn
        # clean up session
        |> delete_session(:oauth_account_type)
        |> json(%{
          message: "OAuth login successful",
          token: token_pair,
          user: %{
            id: user.id,
            email: user.email,
            name: user.name,
            scopes: user.scopes
          }
        })

      {:error, changeset} ->
        conn
        |> delete_session(:oauth_account_type)
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Failed to create user", details: changeset})
    end
  end

  def callback(%{assigns: %{ueberauth_failure: failure}} = conn, _params) do
    conn
    |> delete_session(:oauth_account_type)
    |> put_status(:unauthorized)
    |> json(%{
      error: "OAuth authentication failed",
      details: failure.errors
    })
  end
end
