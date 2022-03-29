defmodule ApiWeb.CommentControllerTest do
  use ApiWeb.ConnCase

  import Api.UsersFixtures
  import Api.BoardsFixtures
  import Api.ListsFixtures
  import Api.TasksFixtures
  import Api.CommentsFixtures

  alias Api.{Repo, Users.User}

  alias Api.Comments.Comment

  @create_attrs %{
    description: "some description"
  }
  @update_attrs %{
    description: "some updated description"
  }
  @invalid_attrs %{description: nil}

  @password "secret1234"

  @valid_params %{"user" => %{"email" => "test1@example.com", "password" => @password}}

  setup do
    user =
      %User{}
      |> User.changeset(%{
        email: "test1@example.com",
        password: @password,
        password_confirmation: @password
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
    test "lists all comments", %{conn: conn} do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      task = task_fixture(user_id, list)

      conn =
        get(conn, Routes.board_list_task_comment_path(conn, :index, board.id, list.id, task.id))

      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create comment" do
    test "renders comment when data is valid", %{conn: conn} do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      task = task_fixture(user_id, list)

      conn =
        post(conn, Routes.board_list_task_comment_path(conn, :create, board.id, list.id, task.id),
          comment: @create_attrs
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn =
        get(
          conn,
          Routes.board_list_task_comment_path(conn, :show, board.id, list.id, task.id, id)
        )

      assert %{
               "id" => ^id,
               "description" => "some description"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user_id = user_fixture()
      board = board_fixture(user_id)
      list = list_fixture(user_id, board)
      task = task_fixture(user_id, list)

      conn =
        post(conn, Routes.board_list_task_comment_path(conn, :create, board.id, list.id, task.id),
          comment: @invalid_attrs
        )

      assert json_response(conn, 400)["error"] == %{"error" => "Cannot create the comment."}
    end
  end

  describe "update comment" do
    setup [:create_comment]

    test "renders comment when data is valid", %{
      conn: conn,
      board: board,
      list: list,
      task: task,
      comment: %Comment{id: id} = comment
    } do
      conn =
        put(
          conn,
          Routes.board_list_task_comment_path(conn, :update, board.id, list.id, task.id, comment),
          comment: @update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn =
        get(
          conn,
          Routes.board_list_task_comment_path(conn, :show, board.id, list.id, task.id, id)
        )

      assert %{
               "id" => ^id,
               "description" => "some updated description"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      board: board,
      list: list,
      task: task,
      comment: comment
    } do
      conn =
        put(
          conn,
          Routes.board_list_task_comment_path(conn, :update, board.id, list.id, task.id, comment),
          comment: @invalid_attrs
        )

      assert json_response(conn, 400)["error"] == %{"error" => "Cannot update the comment."}
    end
  end

  describe "delete comment" do
    setup [:create_comment]

    test "deletes chosen comment", %{
      conn: conn,
      board: board,
      list: list,
      task: task,
      comment: comment
    } do
      conn =
        delete(
          conn,
          Routes.board_list_task_comment_path(conn, :delete, board.id, list.id, task.id, comment)
        )

      assert response(conn, 200) ==
               "{\"data\":{\"message\":\"'some description' comment is deleted.\"}}"

      get_conn =
        get(
          conn,
          Routes.board_list_task_comment_path(conn, :show, board.id, list.id, task.id, comment)
        )

      assert json_response(get_conn, 400)["error"] == %{"error" => "Comment not found."}
    end
  end

  defp create_comment(_) do
    user_id = user_fixture()
    board = board_fixture(user_id)
    list = list_fixture(user_id, board)
    task = task_fixture(user_id, list)
    comment = comment_fixture(user_id, task)
    %{board: board, list: list, task: task, comment: comment}
  end
end
