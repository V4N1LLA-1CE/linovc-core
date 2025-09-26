defmodule VenliCoreWeb.UserController do
  use VenliCoreWeb, :controller

  action_fallback VenliCoreWeb.FallbackController

  def profile(conn, _params) do
    # check claims
    claims = Guardian.Plug.current_claims(conn)
    user_id = claims["sub"]
    user = VenliCore.Accounts.get_user!(user_id)

    conn
    |> put_status(:ok)
    |> json(%{
      profile: user
    })
  end

  def update_profile(conn, params) do
    claims = Guardian.Plug.current_claims(conn)
    user_id = claims["sub"]
    user = VenliCore.Accounts.get_user!(user_id)

    allowed_fields = [
      "name",
      "headline",
      "bio",
      "location",
      "account_type",
      "pfp_url"
    ]

    update_attrs = Map.take(params, allowed_fields)

    case VenliCore.Accounts.update_user(user, update_attrs) do
      {:ok, user} ->
        conn
        |> put_status(:ok)
        |> json(%{
          message: "successfully updated profile",
          profile: user
        })

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
