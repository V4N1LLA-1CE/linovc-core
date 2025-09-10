defmodule LinovcCoreWeb.UserController do
  use LinovcCoreWeb, :controller

  action_fallback LinovcCoreWeb.FallbackController

  alias LinovcCore.UserManager
  alias LinovcCore.UserManager.Guardian

  def profile(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    json(conn, %{
      message: "Profile retrieved successfully",
      user: %{
        id: user.id,
        email: user.email,
        name: user.name,
        headline: user.headline,
        bio: user.bio,
        location: user.location,
        inserted_at: user.inserted_at,
        updated_at: user.updated_at
      }
    })
  end

  def update(conn, params) do
    user = Guardian.Plug.current_resource(conn)

    # only allow updating profile fields, not email password

    params = Map.take(params, ["name", "headline", "bio", "location"])

    case UserManager.update_user(user, params) do
      {:ok, updated_user} ->
        json(conn, %{
          message: "profile updated successfully",
          user: %{
            id: updated_user.id,
            email: updated_user.email,
            name: updated_user.name,
            headline: updated_user.headline,
            bio: updated_user.bio,
            location: updated_user.location,
            updated_at: updated_user.updated_at
          }
        })
    end
  end
end

