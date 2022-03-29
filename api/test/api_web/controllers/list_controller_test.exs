defmodule ApiWeb.ListControllerTest do
  use ApiWeb.ConnCase

  import Api.UsersFixtures
  import Api.BoardsFixtures
  import Api.ListsFixtures

  alias Api.{Repo, Users.User}
  alias Api.Lists.List

  @create_attrs %{
    order: 1,
    title: "some title"
  }
  @update_attrs %{
    order: 1,
    title: "some updated title"
  }
  @invalid_attrs %{order: nil, title: nil}
  @invalid_order_attrs %{order: 5, title: "invalid order list"}

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
    test "lists all lists", %{conn: conn} do
      user_id = user_fixture()
      board = board_fixture(user_id)
      conn = get(conn, Routes.board_list_path(conn, :index, board.id))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create list" do
    test "renders list when data is valid", %{conn: conn} do
      user_id = user_fixture()
      board = board_fixture(user_id)
      conn = post(conn, Routes.board_list_path(conn, :create, board.id), list: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.board_list_path(conn, :show, board.id, id))

      assert %{
               "id" => ^id,
               "order" => 1,
               "title" => "some title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user_id = user_fixture()
      board = board_fixture(user_id)
      conn = post(conn, Routes.board_list_path(conn, :create, board.id), list: @invalid_attrs)
      assert json_response(conn, 400)["error"] == %{"error" => "Cannot create the list."}
    end

    test "renders order error when order is invalid", %{conn: conn} do
      user_id = user_fixture()
      board = board_fixture(user_id)

      conn =
        post(conn, Routes.board_list_path(conn, :create, board.id), list: @invalid_order_attrs)

      assert json_response(conn, 400)["error"] == %{
               "error" => "Assigned 'order' is out of valid range."
             }
    end
  end

  describe "update list" do
    setup [:create_list]

    test "renders list when data is valid", %{
      conn: conn,
      board: board,
      list: %List{id: id} = _list
    } do
      conn = put(conn, Routes.board_list_path(conn, :update, board.id, id), list: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.board_list_path(conn, :show, board, id))

      assert %{
               "id" => ^id,
               "order" => 1,
               "title" => "some updated title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, board: board, list: list} do
      conn =
        put(conn, Routes.board_list_path(conn, :update, board.id, list.id), list: @invalid_attrs)

      assert json_response(conn, 400)["error"] == %{"error" => "Cannot update the list."}
    end

    test "renders order error when order is invalid", %{conn: conn, board: board, list: list} do
      conn =
        put(conn, Routes.board_list_path(conn, :update, board.id, list.id),
          list: @invalid_order_attrs
        )

      assert json_response(conn, 400)["error"] == %{
               "error" => "Assigned 'order' is out of valid range."
             }
    end
  end

  describe "delete list" do
    setup [:create_list]

    test "deletes chosen list", %{conn: conn, board: board, list: list} do
      conn = get(conn, Routes.board_list_path(conn, :show, board, list.id))

      conn = delete(conn, Routes.board_list_path(conn, :delete, board.id, list.id))
      assert response(conn, 200) == "{\"data\":{\"message\":\"'some title' list is deleted.\"}}"

      get_conn = get(conn, Routes.board_list_path(conn, :show, board, list.id))
      assert json_response(get_conn, 400)["error"] == %{"error" => "List not found."}
    end
  end

  defp create_list(_) do
    user_id = user_fixture()
    board = board_fixture(user_id)
    list = list_fixture(user_id, board)
    %{board: board, list: list}
  end
end
