defmodule Api.ListsTest do
  use Api.DataCase

  alias Api.Lists

  describe "lists" do
    alias Api.Lists.List

    import Api.UsersFixtures
    import Api.BoardsFixtures
    import Api.ListsFixtures

    @invalid_attrs %{order: nil, title: nil}
    @invalid_order_attrs %{order: 5, title: "invalid order list"}

    test "list_lists/0 returns all lists" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      assert Lists.list_lists(board.id) == {:ok, [list]}
    end

    test "get_list/1 returns the list with given id" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      {:ok, specific_list} = Lists.get_list(board.id, list.id)
      assert specific_list == list
    end

    test "create_list/1 with valid data creates a list" do
      user = user_fixture()
      board = board_fixture(user)
      _list = list_fixture(user, board)
      valid_attrs = %{order: 1, title: "some title", user_id: user.id}

      assert {:ok, %List{} = list} = Lists.create_list(board, valid_attrs)
      assert list.order == 1
      assert list.title == "some title"
    end

    test "create_list/1 with invalid data returns generic error" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      assert {:error, "Cannot create the list."} = Lists.create_list(board, @invalid_attrs)
    end

    test "create_list/1 with invalid order returns assigned order error" do
      user_id = user_fixture()
      board = board_fixture(user_id)

      assert {:error, "Assigned 'order' is out of valid range."} =
               Lists.create_list(board, @invalid_order_attrs)
    end

    test "update_list/2 with valid data updates the list" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      update_attrs = %{order: 1, title: "some updated title"}

      assert {:ok, %List{} = list} = Lists.update_list(board, list, update_attrs)
      assert list.order == 1
      assert list.title == "some updated title"
    end

    test "update_list/2 with invalid data returns error generic error" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      assert {:error, "Cannot update the list."} = Lists.update_list(board, list, @invalid_attrs)

      {:ok, get_list} = Lists.get_list(board.id, list.id)
      assert list == get_list
    end

    test "update_list/2 with invalid order returns assigned order error" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)

      assert {:error, "Assigned 'order' is out of valid range."} =
               Lists.update_list(board, list, @invalid_order_attrs)

      {:ok, get_list} = Lists.get_list(board.id, list.id)
      assert list == get_list
    end

    test "delete_list/1 deletes the list" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      assert {:ok, "'some title' list is deleted."} = Lists.delete_list(board, list)
      assert {:not_found, "List not found."} = Lists.get_list(board.id, list.id)
    end

    test "change_list/1 returns a list changeset" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      assert %Ecto.Changeset{} = Lists.change_list(list)
    end
  end
end
