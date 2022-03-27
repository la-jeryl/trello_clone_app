defmodule Api.ListsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Api.Lists` context.
  """

  @doc """
  Generate a list.
  """
  def list_fixture(board) do
    # {:ok, list} =
    #   attrs
    #   |> Enum.into(%{
    #     order: 42,
    #     title: "some title"
    #   })
    #   |> Api.Lists.create_list()

    params = %{
      order: 1,
      title: "some title"
    }

    {:ok, list} = Api.Lists.create_list(board, params)

    list
  end
end
