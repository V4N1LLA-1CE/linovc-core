defmodule VenliCore.Auth.TokenGenerator do
  @moduledoc """
  Shared token generation utilities for authentication.
  """

  alias VenliCore.Accounts.Guardian

  @doc """
  Generates an access/refresh token pair for a user.
  """
  def generate_token_pair(user) do
    {:ok, access_token, _claims} = Guardian.encode_and_sign(user, %{}, token_type: "access")
    {:ok, refresh_token, _claims} = Guardian.encode_and_sign(user, %{}, token_type: "refresh")

    %{
      access: access_token,
      refresh: refresh_token
    }
  end
end

