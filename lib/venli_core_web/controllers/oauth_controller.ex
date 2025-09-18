defmodule VenliCoreWeb.OAuthController do
  use VenliCoreWeb, :controller
  plug Ueberauth

  action_fallback VenliCoreWeb.FallbackController

  alias VenliCore.Accounts
  alias VenliCore.Auth.TokenGenerator

  def request(conn, _params) do
    conn
    # ueberauth will handle the redirect, but we need a fallback response
    |> json(%{message: "OAuth initialization failed"})
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case Accounts.create_or_link_oauth_user(auth) do
      {:ok, user} ->
        token_pair = TokenGenerator.generate_token_pair(user)

        conn
        |> json(%{
          message: "OAuth login successful",
          token: token_pair,
          user: user
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Failed to create user", details: changeset})
    end
  end

  def callback(%{assigns: %{ueberauth_failure: failure}} = conn, _params) do
    conn
    |> put_status(:unauthorized)
    |> json(%{
      error: "OAuth authentication failed",
      details: failure.errors
    })
  end
end
