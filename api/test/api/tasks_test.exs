defmodule Api.TasksTest do
  use Api.DataCase

  alias Api.Tasks

  describe "tasks" do
    alias Api.Tasks.Task

    import Api.UsersFixtures
    import Api.BoardsFixtures
    import Api.ListsFixtures
    import Api.TasksFixtures

    @invalid_attrs %{description: nil, order: nil, status: :not_started, title: nil}
    @invalid_status_attrs %{description: nil, order: nil, status: nil, title: nil}
    @invalid_order_attrs %{description: nil, order: 2, status: :not_started, title: nil}

    test "list_tasks/1 returns all tasks" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      task = task_fixture(user_id, list)
      assert Tasks.list_tasks(list.id) == {:ok, [task]}
    end

    test "get_task/2 returns the task with given id" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      task = task_fixture(user_id, list)
      {:ok, specific_task} = Tasks.get_task(list.id, task.id)
      assert specific_task == task
    end

    test "create_task/1 with valid data creates a task" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      _task = task_fixture(user_id, list)

      valid_attrs = %{
        description: "some description",
        order: 1,
        status: :not_started,
        title: "some title",
        user_id: user_id
      }

      assert {:ok, %Task{} = task} = Tasks.create_task(list, valid_attrs)
      assert task.description == "some description"
      assert task.order == 1
      assert task.status == :not_started
      assert task.title == "some title"
    end

    test "create_task/1 with invalid data returns error changeset" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      _task = task_fixture(user_id, list)
      assert {:error, "Cannot create the task."} = Tasks.create_task(list, @invalid_attrs)
    end

    test "create_task/1 with invalid status returns error changeset" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      _task = task_fixture(user_id, list)
      assert {:error, "Invalid task status."} = Tasks.create_task(list, @invalid_status_attrs)
    end

    test "create_task/1 with invalid order returns error changeset" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      _task = task_fixture(user_id, list)

      assert {:error, "Assigned 'order' is out of valid range."} =
               Tasks.create_task(list, @invalid_order_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      task = task_fixture(user_id, list)

      update_attrs = %{
        description: "some updated description",
        order: 1,
        status: :in_progress,
        title: "some updated title",
        user_id: user_id
      }

      assert {:ok, %Task{} = task} = Tasks.update_task(list, task, update_attrs)
      assert task.description == "some updated description"
      assert task.order == 1
      assert task.status == :in_progress
      assert task.title == "some updated title"
    end

    test "update_task/2 with invalid data returns error changeset" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      task = task_fixture(user_id, list)
      assert {:error, "Cannot update the task."} = Tasks.update_task(list, task, @invalid_attrs)
      assert {:ok, task} == Tasks.get_task(list.id, task.id)
    end

    test "update_task/2 with invalid status returns error changeset" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      task = task_fixture(user_id, list)

      assert {:error, "Invalid task status."} =
               Tasks.update_task(list, task, @invalid_status_attrs)

      assert {:ok, task} == Tasks.get_task(list.id, task.id)
    end

    test "update_task/2 with invalid order returns error changeset" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      task = task_fixture(user_id, list)

      assert {:error, "Assigned 'order' is out of valid range."} =
               Tasks.update_task(list, task, @invalid_order_attrs)

      assert {:ok, task} == Tasks.get_task(list.id, task.id)
    end

    test "delete_task/1 deletes the task" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      task = task_fixture(user_id, list)
      assert {:ok, "'some title' task is deleted."} = Tasks.delete_task(list, task)
      assert {:not_found, "Task not found."} = Tasks.get_task(list.id, task.id)
    end

    test "change_task/1 returns a task changeset" do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      task = task_fixture(user_id, list)
      assert %Ecto.Changeset{} = Tasks.change_task(task)
    end
  end
end
