defmodule VenliCore.Auth.Cookies do
  @refresh_cookie_key "venli-refresh-token"

  def refresh_cookie_key, do: @refresh_cookie_key
end
