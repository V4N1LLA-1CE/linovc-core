defmodule VenliCoreWeb.OAuthController do
  use VenliCoreWeb, :controller
  plug Ueberauth

  action_fallback VenliCoreWeb.FallbackController

  alias VenliCore.Auth.Cookies
  alias VenliCore.Accounts
  alias VenliCore.Auth.TokenGenerator

  def request(conn, _params) do
    # oauth initiation gets handled by ueberauth
    #
    # in any case this fails, 
    # have a fallback for internal server error
    conn
    |> put_status(:internal_server_error)
    |> json(%{message: "OAuth initialization failed"})
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case Accounts.create_or_link_oauth_user(auth) do
      {:ok, user} ->
        token_pair = TokenGenerator.generate_token_pair(user)

        # for this response:
        # return access token in json
        # store refresh token in httpscookie 7 days
        # redirect to frontend callback page with access token
        frontend_url = System.get_env("FRONTEND_URL") || "http://localhost:3000"

        conn
        |> put_resp_cookie(Cookies.refresh_cookie_key(), token_pair.refresh,
          http_only: true,
          secure: Mix.env() == :prod,
          same_site: "Lax",
          max_age: 7 * 24 * 60 * 60
        )
        |> redirect(external: "#{frontend_url}/oauth/callback?token=#{token_pair.access}")

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
