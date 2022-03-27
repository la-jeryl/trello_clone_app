defmodule Api.ListsTest do
  use Api.DataCase

  alias Api.Lists

  describe "lists" do
    alias Api.Lists.List
    alias Api.Boards

    import Api.BoardsFixtures
    import Api.ListsFixtures

    @invalid_attrs %{order: nil, title: nil}

    test "list_lists/0 returns all lists" do
      board = board_fixture()
      list = list_fixture(board)
      assert Lists.list_lists(board) == {:ok, [list]}
    end

    test "get_list/1 returns the list with given id" do
      board = board_fixture()
      list = list_fixture(board)
      {:ok, updated_board} = Boards.get_board(board.id)
      {:ok, specific_list} = Lists.get_list(updated_board, list.id)
      assert specific_list == list
    end

    test "create_list/1 with valid data creates a list" do
      board = board_fixture()
      valid_attrs = %{order: 1, title: "some title"}

      assert {:ok, %List{} = list} = Lists.create_list(board, valid_attrs)
      assert list.order == 1
      assert list.title == "some title"
    end

    test "create_list/1 with invalid data returns error changeset" do
      board = board_fixture()
      assert {:error, "Cannot create the list."} = Lists.create_list(board, @invalid_attrs)
    end

    test "update_list/2 with valid data updates the list" do
      board = board_fixture()
      list = list_fixture(board)
      update_attrs = %{order: 2, title: "some updated title"}

      assert {:ok, %List{} = list} = Lists.update_list(board, list, update_attrs)
      assert list.order == 2
      assert list.title == "some updated title"
    end

    test "update_list/2 with invalid data returns error changeset" do
      board = board_fixture()
      list = list_fixture(board)
      assert {:error, "Cannot update the list."} = Lists.update_list(board, list, @invalid_attrs)
      {:ok, updated_board} = Boards.get_board(board.id)
      {:ok, get_list} = Lists.get_list(updated_board, list.id)
      assert list == get_list
    end

    test "delete_list/1 deletes the list" do
      board = board_fixture()
      list = list_fixture(board)
      assert {:ok, "'some title' list is deleted."} = Lists.delete_list(board, list)
      {:ok, updated_board} = Boards.get_board(board.id)
      assert {:not_found, "List not found."} = Lists.get_list(updated_board, list.id)
    end

    test "change_list/1 returns a list changeset" do
      board = board_fixture()
      list = list_fixture(board)
      assert %Ecto.Changeset{} = Lists.change_list(list)
    end
  end
end
