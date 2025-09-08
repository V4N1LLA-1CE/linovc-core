defmodule LinovcCoreWeb.AuthController do
  use LinovcCoreWeb, :controller

  action_fallback LinovcCoreWeb.FallbackController

  alias LinovcCore.UserManager
  alias LinovcCore.UserManager.Guardian

  def register(conn, %{"user" => user_params}) do
    case UserManager.create_user(user_params) do
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)

        conn
        |> put_status(:created)
        |> json(%{
          message: "user created successfully",
          token: token,
          user: %{
            id: user.id,
            email: user.email
          }
        })

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def register(_conn, _params), do: {:error, :"register request failed"}

  def login(conn, %{"email" => email, "password" => password}) do
    case UserManager.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)

        json(conn, %{
          message: "login successful",
          token: token,
          user: %{
            id: user.id,
            email: user.email
          }
        })

      {:error, :invalid_credentials} ->
        {:error, :unauthorized}
    end
  end

  def login(_conn, _params), do: {:error, :"login request failed"}
end
