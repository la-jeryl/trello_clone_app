defmodule Api.BoardsTest do
  use Api.DataCase

  alias Api.Boards

  describe "boards" do
    alias Api.Boards.Board

    import Api.UsersFixtures
    import Api.BoardsFixtures

    @invalid_attrs %{title: nil}

    test "list_boards/0 returns all boards" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      assert Boards.list_boards() == {:ok, [board]}
    end

    test "get_board/1 returns the board with given id" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      assert Boards.get_board(board.id) == {:ok, board}
    end

    test "create_board/1 with valid data creates a board" do
      user = user_fixture()
      valid_attrs = %{title: "some title", user_id: user.id}
      assert {:ok, %Board{} = board} = Boards.create_board(valid_attrs)
      assert board.title == "some title"
    end

    test "create_board/1 with invalid data returns generic error" do
      assert {:error, "Cannot create the board."} = Boards.create_board(@invalid_attrs)
    end

    test "update_board/2 with valid data updates the board" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      update_attrs = %{title: "some updated title"}

      assert {:ok, %Board{} = board} = Boards.update_board(board, update_attrs)
      assert board.title == "some updated title"
    end

    test "update_board/2 with invalid data returns generic error" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      assert {:error, "Cannot update the board."} = Boards.update_board(board, @invalid_attrs)
      assert {:ok, board} == Boards.get_board(board.id)
    end

    test "delete_board/1 deletes the board" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      assert {:ok, _message} = Boards.delete_board(board)
      assert Boards.get_board(board.id) == {:not_found, "Board not found."}
    end

    test "change_board/1 returns a board changeset" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      assert %Ecto.Changeset{} = Boards.change_board(board)
    end
  end
end
