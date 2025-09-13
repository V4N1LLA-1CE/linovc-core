defmodule LinovcCoreWeb.Plugs.EnsureAccessToken do
  import Phoenix.Controller
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case Guardian.Plug.current_claims(conn) do
      %{"typ" => "access"} ->
        conn

      %{"typ" => other_type} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{
          message: "this token type is not allowed",
          received: other_type
        })
        |> halt()

      _claims_without_typ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{
          message: "invalid token"
        })
        |> halt()
    end
  end
end
