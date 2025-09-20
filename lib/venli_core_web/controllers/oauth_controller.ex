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
    frontend_url = Application.get_env(:venli_core, :frontend_url)

    case Accounts.create_or_link_oauth_user(auth) do
      {:ok, user} ->
        token_pair = TokenGenerator.generate_token_pair(user)

        # for this response:
        # return access token in json
        # store refresh token in httpscookie 7 days
        # redirect to frontend callback page with access token

        conn
        |> put_resp_cookie(Cookies.refresh_cookie_key(), token_pair.refresh, Cookies.refresh_cookie_opts())
        |> put_status(302)
        |> redirect(external: "#{frontend_url}/oauth/callback?token=#{token_pair.access}")

      {:error, _changeset} ->
        conn
        |> put_status(302)
        |> redirect(external: "#{frontend_url}/oauth/callback")
    end
  end

  def callback(%{assigns: %{ueberauth_failure: _failure}} = conn, _params) do
    frontend_url = Application.get_env(:venli_core, :frontend_url)

    conn
    |> put_status(302)
    |> redirect(external: "#{frontend_url}/oauth/callback")
  end
end
