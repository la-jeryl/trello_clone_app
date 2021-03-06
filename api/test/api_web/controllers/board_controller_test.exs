defmodule ApiWeb.BoardControllerTest do
  use ApiWeb.ConnCase

  import Api.UsersFixtures
  import Api.BoardsFixtures

  alias Api.{Repo, Users.User}
  alias Api.Boards.Board

  @create_attrs %{
    title: "some title"
  }
  @update_attrs %{
    title: "some updated title"
  }
  @invalid_attrs %{title: nil}

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
    test "lists all boards", %{conn: conn} do
      conn = get(conn, Routes.board_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create board" do
    test "renders board when data is valid", %{conn: conn} do
      conn = post(conn, Routes.board_path(conn, :create), board: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.board_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "title" => "some title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.board_path(conn, :create), board: @invalid_attrs)
      assert json_response(conn, 400) == %{"error" => %{"error" => "Cannot create the board."}}
    end
  end

  describe "update board" do
    setup [:create_board]

    test "renders board when data is valid", %{conn: conn, board: %Board{id: id} = board} do
      conn = put(conn, Routes.board_path(conn, :update, board), board: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.board_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "title" => "some updated title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, board: board} do
      conn = put(conn, Routes.board_path(conn, :update, board), board: @invalid_attrs)
      assert json_response(conn, 400) == %{"error" => %{"error" => "Cannot update the board."}}
    end
  end

  describe "delete board" do
    setup [:create_board]

    test "deletes chosen board", %{conn: conn, board: board} do
      conn = delete(conn, Routes.board_path(conn, :delete, board))
      assert response(conn, 200) == "{\"data\":{\"message\":\"'some title' board is deleted.\"}}"

      get_conn = get(conn, Routes.board_path(conn, :show, board))
      assert response(get_conn, 400) == "{\"error\":{\"error\":\"Board not found.\"}}"
    end
  end

  defp create_board(_) do
    user_id = user_fixture()
    board = board_fixture(user_id)
    %{board: board}
  end
end
