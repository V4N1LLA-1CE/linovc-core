defmodule LinovcCore.UserManagerFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LinovcCore.UserManager` context.
  """

  @doc """
  Generate a unique user email.
  """
  def unique_user_email, do: "#{System.unique_integer([:positive])}@gmail.com"

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: unique_user_email(),
        password: "some password"
      })
      |> LinovcCore.UserManager.create_user()

    user
  end
end
