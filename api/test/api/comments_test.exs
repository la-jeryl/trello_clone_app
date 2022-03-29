defmodule Api.CommentsTest do
  use Api.DataCase

  alias Api.Comments

  describe "comments" do
    alias Api.Comments.Comment

    import Api.UsersFixtures
    import Api.BoardsFixtures
    import Api.ListsFixtures
    import Api.TasksFixtures
    import Api.CommentsFixtures

    @invalid_attrs %{description: nil}

    test "list_comments/0 returns all comments" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      task = task_fixture(user_id, list)
      comment = comment_fixture(user_id, task)
      assert Comments.list_comments(task.id) == {:ok, [comment]}
    end

    test "get_comment!/1 returns the comment with given id" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      task = task_fixture(user_id, list)
      comment = comment_fixture(user_id, task)
      assert Comments.get_comment(task.id, comment.id) == {:ok, comment}
    end

    test "create_comment/1 with valid data creates a comment" do
      user = user_fixture()
      board = board_fixture(user)
      list = list_fixture(user, board)
      task = task_fixture(user, list)
      valid_attrs = %{description: "some description", user_id: user.id}

      assert {:ok, %Comment{} = comment} = Comments.create_comment(task, valid_attrs)
      assert comment.description == "some description"
    end

    test "create_comment/2 with invalid data returns error" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      task = task_fixture(user_id, list)

      assert {:error, "Cannot create the comment."} =
               Comments.create_comment(task, @invalid_attrs)
    end

    test "update_comment/2 with valid data updates the comment" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      task = task_fixture(user_id, list)
      comment = comment_fixture(user_id, task)
      update_attrs = %{description: "some updated description"}

      assert {:ok, %Comment{} = comment} = Comments.update_comment(comment, update_attrs)
      assert comment.description == "some updated description"
    end

    test "update_comment/2 with invalid data returns error" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      task = task_fixture(user_id, list)
      comment = comment_fixture(user_id, task)

      assert {:error, "Cannot update the comment."} =
               Comments.update_comment(comment, @invalid_attrs)

      assert {:ok, comment} == Comments.get_comment(task.id, comment.id)
    end

    test "delete_comment/1 deletes the comment" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      task = task_fixture(user_id, list)
      comment = comment_fixture(user_id, task)
      assert {:ok, "'some description' comment is deleted."} = Comments.delete_comment(comment)
      assert {:not_found, "Comment not found."} == Comments.get_comment(task.id, comment.id)
    end

    test "change_comment/1 returns a comment changeset" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      task = task_fixture(user_id, list)
      comment = comment_fixture(user_id, task)
      assert %Ecto.Changeset{} = Comments.change_comment(comment)
    end
  end
end
