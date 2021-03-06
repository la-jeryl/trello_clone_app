defmodule Api.BoardsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Api.Boards` context.
  """

  @doc """
  Generate a board.
  """
  def board_fixture(user) do
    params = %{
      title: "some title",
      user_id: user.id
    }

    {:ok, board} = Api.Boards.create_board(params)

    board
  end
end
