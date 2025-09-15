defmodule LinovcCore.Auth.Permissions do
  @valid_scopes ["founder:default", "vc:default"]
  def valid_scopes, do: @valid_scopes
end
