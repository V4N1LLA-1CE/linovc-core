defmodule VenliCore.Auth.Permissions do
  @valid_scopes ~w(user:default)
  def valid_scopes, do: @valid_scopes

  def default_scope, do: "user:default"
end
