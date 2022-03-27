defmodule Api.ListsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Api.Lists` context.
  """

  @doc """
  Generate a list.
  """
  def list_fixture(board) do
    params = %{
      order: 1,
      title: "some title"
    }

    {:ok, list} = Api.Lists.create_list(board, params)

    list
  end
end
