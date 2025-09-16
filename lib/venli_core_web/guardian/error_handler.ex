defmodule VenliCoreWeb.Guardian.ErrorHandler do
  import Plug.Conn
  import Phoenix.Controller

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    message =
      case type do
        :invalid_token -> "Invalid token"
        :unauthenticated -> "Authentication required"
        :no_resource_found -> "User not found"
        _ -> "Authentication failed"
      end

    conn
    |> put_status(:unauthorized)
    |> put_view(VenliCoreWeb.ErrorJSON)
    |> render(:"401", %{message: message})
  end
end

