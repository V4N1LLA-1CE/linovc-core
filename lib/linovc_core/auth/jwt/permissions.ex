defmodule LinovcCore.Auth.JWT.Permissions do
  @valid_scopes ["user:default"]
  def valid_scopes, do: @valid_scopes
end
