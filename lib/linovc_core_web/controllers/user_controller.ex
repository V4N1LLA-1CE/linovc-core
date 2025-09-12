defmodule LinovcCoreWeb.UserController do
  use LinovcCoreWeb, :controller

  action_fallback LinovcCoreWeb.FallbackController

  alias LinovcCore.UserManager
  alias LinovcCore.UserManager.Guardian

  def profile(conn, _params) do
    claims = Guardian.Plug.current_claims(conn)
    user = UserManager.get_user!(claims["sub"])

    json(conn, %{
      message: "Profile retrieved successfully",
      user: user
    })
  end

  def update(conn, params) do
    claims = Guardian.Plug.current_claims(conn)
    user = UserManager.get_user!(claims["sub"])

    # only allow updating profile fields, not email password

    params = Map.take(params, ["name", "headline", "bio", "location"])

    case UserManager.update_user(user, params) do
      {:ok, updated_user} ->
        json(conn, %{
          message: "profile updated successfully",
          user: updated_user
        })
    end
  end
end
