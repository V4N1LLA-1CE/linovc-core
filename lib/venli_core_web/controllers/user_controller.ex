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
end
