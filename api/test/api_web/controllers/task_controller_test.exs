defmodule ApiWeb.TaskControllerTest do
  use ApiWeb.ConnCase

  import Api.UsersFixtures
  import Api.BoardsFixtures
  import Api.ListsFixtures
  import Api.TasksFixtures

  alias Api.{Repo, Users.User}
  alias Api.Tasks.Task

  @create_attrs %{
    description: "some description",
    order: 1,
    status: :not_started,
    title: "some title"
  }
  @update_attrs %{
    description: "some updated description",
    order: 1,
    status: :in_progress,
    title: "some updated title"
  }
  @invalid_attrs %{description: nil, order: nil, status: :not_started, title: nil}
  @invalid_order_attrs %{order: 5, status: :not_started, title: "invalid task order"}
  @invalid_status_attrs %{order: 1, title: "invalid task status", status: "some_status"}

  @password "secret1234"

  @valid_params %{"user" => %{"email" => "test1@example.com", "password" => @password}}

  setup do
    user =
      %User{}
      |> User.changeset(%{
        email: "test1@example.com",
        password: @password,
        password_confirmation: @password,
        role: "manage"
      })
      |> Repo.insert!()

    {:ok, user: user}
  end

  setup %{conn: conn} do
    auth = post(conn, Routes.session_path(conn, :create, @valid_params))
    json = json_response(auth, 200)

    authed_conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", json["data"]["access_token"])

    {:ok, conn: authed_conn}
  end

  describe "index" do
    test "lists all tasks", %{conn: conn} do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      conn = get(conn, Routes.board_list_task_path(conn, :index, board.id, list.id))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create task" do
    test "renders task when data is valid", %{conn: conn} do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)

      conn =
        post(conn, Routes.board_list_task_path(conn, :create, board.id, list.id),
          task: @create_attrs
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.board_list_task_path(conn, :show, board.id, list.id, id))

      assert %{
               "id" => ^id,
               "description" => "some description",
               "order" => 1,
               "status" => "not_started",
               "title" => "some title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)

      conn =
        post(conn, Routes.board_list_task_path(conn, :create, board.id, list.id),
          task: @invalid_attrs
        )

      assert json_response(conn, 400)["error"] == %{"error" => "Cannot create the task."}
    end

    test "renders order error when order is invalid", %{conn: conn} do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)

      conn =
        post(conn, Routes.board_list_task_path(conn, :create, board.id, list.id),
          task: @invalid_order_attrs
        )

      assert json_response(conn, 400)["error"] == %{
               "error" => "Assigned 'order' is out of valid range."
             }
    end

    test "renders order error when status is invalid", %{conn: conn} do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)

      conn =
        post(conn, Routes.board_list_task_path(conn, :create, board.id, list.id),
          task: @invalid_status_attrs
        )

      assert json_response(conn, 400)["error"] == %{
               "error" => "Invalid task status."
             }
    end
  end

  describe "update task" do
    setup [:create_task]

    test "renders task when data is valid", %{
      conn: conn,
      board: board,
      list: list,
      task: %Task{id: id} = _task
    } do
      conn =
        put(conn, Routes.board_list_task_path(conn, :update, board.id, list.id, id),
          task: @update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.board_list_task_path(conn, :show, board.id, list.id, id))

      assert %{
               "id" => ^id,
               "description" => "some updated description",
               "order" => 1,
               "status" => "in_progress",
               "title" => "some updated title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      board: board,
      list: list,
      task: task
    } do
      conn =
        put(conn, Routes.board_list_task_path(conn, :update, board.id, list.id, task.id),
          task: @invalid_attrs
        )

      assert json_response(conn, 400)["error"] ==
               %{"error" => "Cannot update the task."}
    end
  end

  describe "delete task" do
    setup [:create_task]

    test "deletes chosen task", %{conn: conn, board: board, list: list, task: task} do
      conn = delete(conn, Routes.board_list_task_path(conn, :delete, board.id, list.id, task.id))
      assert response(conn, 200) == "{\"data\":{\"message\":\"'some title' task is deleted.\"}}"

      get_conn = get(conn, Routes.board_list_task_path(conn, :show, board.id, list.id, task.id))
      assert json_response(get_conn, 400)["error"] == %{"error" => "Task not found."}
    end
  end

  defp create_task(_) do
    user_id = user_fixture()
    board = board_fixture(user_id)
    list = list_fixture(user_id, board)
    task = task_fixture(user_id, list)
    %{board: board, list: list, task: task}
  end
end
