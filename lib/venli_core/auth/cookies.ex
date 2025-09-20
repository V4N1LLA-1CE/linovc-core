defmodule VenliCore.Auth.Cookies do
  @moduledoc """
  Utilities for managing authentication cookies.

  This module provides standardized cookie configurations for authentication
  tokens, ensuring consistent security settings across the application.
  """

  @refresh_cookie_key "venli-refresh-token"

  @doc """
  Returns the key used for refresh token cookies.
  """
  def refresh_cookie_key, do: @refresh_cookie_key

  @doc """
  Returns standard options for setting refresh token cookies.

  Options include:
  - `http_only: true` - Prevents JavaScript access for security
  - `secure: true` - HTTPS only in production
  - `same_site: "Lax"` - CSRF protection
  - `max_age: 604800` - 7 days expiration
  """
  def refresh_cookie_opts do
    [
      http_only: true,
      secure: Mix.env() == :prod,
      same_site: "Lax",
      max_age: 7 * 24 * 60 * 60
    ]
  end

  @doc """
  Returns standard options for deleting refresh token cookies.

  Uses the same security settings as `refresh_cookie_opts/0` but without
  the `max_age` to ensure proper cookie deletion.
  """
  def delete_refresh_cookie_opts do
    [
      http_only: true,
      secure: Mix.env() == :prod,
      same_site: "Lax"
    ]
  end
end
