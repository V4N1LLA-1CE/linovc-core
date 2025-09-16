defmodule VenliCoreWeb.OAuthController do
  use VenliCoreWeb, :controller
  plug Ueberauth

  action_fallback VenliCoreWeb.FallbackController

  alias VenliCore.Accounts
  alias VenliCore.Auth.TokenGenerator

  def request(conn, params) do
    # build Google OAuth URL manually - read env var directly at runtime
    client_id = System.get_env("GOOGLE_CLIENT_ID")

    redirect_uri = "#{VenliCoreWeb.Endpoint.url()}/api/auth/google/callback"

    # preserve account_type in state parameter
    state = params["account_type"] || "vc:default"

    oauth_url =
      "https://accounts.google.com/o/oauth2/v2/auth?" <>
        URI.encode_query(%{
          client_id: client_id,
          redirect_uri: redirect_uri,
          response_type: "code",
          scope: "openid email profile",
          state: state
        })

    redirect(conn, external: oauth_url)
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
    # get account_type from state parameter
    account_type = params["state"] || "vc:default"

    case Accounts.create_or_update_oauth_user(auth, account_type) do
      {:ok, user} ->
        token_pair = TokenGenerator.generate_token_pair(user)

        json(conn, %{
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
        {:error, changeset}
    end
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    json(conn |> put_status(:unauthorized), %{
      error: "OAuth authentication failed"
    })
  end

  def callback(conn, params) do
    # Handle manual OAuth callback (when not using Ueberauth processing)
    if params["code"] do
      handle_manual_callback(conn, params)
    else
      {:error, :bad_request}
    end
  end

  defp handle_manual_callback(conn, %{"code" => code, "state" => account_type}) do
    case exchange_code_for_token(code) do
      {:ok, user_info} ->
        case Accounts.create_or_update_oauth_user(user_info, account_type) do
          {:ok, user} ->
            token_pair = TokenGenerator.generate_token_pair(user)

            json(conn, %{
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
            {:error, changeset}
        end

      {:error, reason} ->
        json(conn |> put_status(:unauthorized), %{
          error: "Failed to exchange code for token: #{reason}"
        })
    end
  end

  defp exchange_code_for_token(code) do
    client_id = System.get_env("GOOGLE_CLIENT_ID")
    client_secret = System.get_env("GOOGLE_CLIENT_SECRET")

    redirect_uri = "#{VenliCoreWeb.Endpoint.url()}/api/auth/google/callback"

    # Exchange code for access token
    token_url = "https://oauth2.googleapis.com/token"

    token_params = %{
      client_id: client_id,
      client_secret: client_secret,
      code: code,
      grant_type: "authorization_code",
      redirect_uri: redirect_uri
    }

    case Req.post(token_url, form: token_params) do
      {:ok, %{status: 200, body: %{"access_token" => access_token}}} ->
        # Get user info using access token
        user_info_url =
          "https://www.googleapis.com/oauth2/v2/userinfo?access_token=#{access_token}"

        case Req.get(user_info_url) do
          {:ok, %{status: 200, body: user_data}} ->
            # Format to match Ueberauth structure
            formatted_auth = %{
              info: %{
                email: user_data["email"],
                name: user_data["name"]
              }
            }

            {:ok, formatted_auth}

          error ->
            {:error, "Failed to get user info: #{inspect(error)}"}
        end

      error ->
        {:error, "Token exchange failed: #{inspect(error)}"}
    end
  end
end
