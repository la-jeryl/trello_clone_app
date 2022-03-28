defmodule Api.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Api.Boards` context.
  """

  alias Api.{Repo, Users.User}

  @password "secret1234"

  @doc """
  Generate a user.
  """

  def user_fixture() do
    user =
      %User{}
      |> User.changeset(%{
        email: "test@example.com",
        password: @password,
        password_confirmation: @password
      })
      |> Repo.insert!()

    user.id
  end
end
