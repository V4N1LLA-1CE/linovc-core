defmodule LinovcCoreWeb.UserController do
  use LinovcCoreWeb, :controller
  
  action_fallback LinovcCoreWeb.FallbackController
  
  alias LinovcCore.UserManager.Guardian

  def profile(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    
    json(conn, %{
      message: "Profile retrieved successfully",
      user: %{
        id: user.id,
        email: user.email,
        inserted_at: user.inserted_at,
        updated_at: user.updated_at
      }
    })
  end
end