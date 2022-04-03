defmodule ClientWeb.NewBoardController do
  use ClientWeb, :controller

  alias Client.Boards
  alias Client.Helpers

  def new(conn, _params) do
    initial_boards_list = Plug.Conn.get_session(conn, :boards)
    render(conn, "new_board.html", error_message: nil, boards: initial_boards_list)
  end

  def create(conn, %{"board" => board_params}) do
    user_id = Plug.Conn.get_session(conn, :current_user)["id"]
    initial_boards_list = Plug.Conn.get_session(conn, :boards)
    initial_board_id = Plug.Conn.get_session(conn, :board_id)
    user_token = Plug.Conn.get_session(conn, :user_token)
    board_body = Map.put(board_params, "user_id", user_id)

    case Boards.create_board(user_token, %{board: Helpers.key_to_atom(board_body)}) do
      {:ok, new_board} ->
        case Boards.list_boards(user_token) do
          {:ok, updated_boards_list} ->
            conn
            |> put_flash(:info, "'#{new_board["title"]}' board created successfully.")
            |> put_session(:boards, updated_boards_list)
            |> put_session(:board_id, new_board["id"])
            |> redirect(to: "/boards")

          {:error, reason} ->
            conn
            |> put_session(:boards, initial_boards_list)
            |> put_session(:board_id, initial_board_id)
            |> render("new_board.html",
              error_message: reason["error"],
              boards: initial_boards_list
            )
        end

      {:error, reason} ->
        conn
        |> put_session(:boards, initial_boards_list)
        |> put_session(:board_id, initial_board_id)
        |> put_flash(:error, reason["error"])
        |> render("new_board.html", error_message: nil, boards: initial_boards_list)
    end
  end
end
