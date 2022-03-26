defmodule ApiWeb.BoardController do
  use ApiWeb, :controller

  alias Api.Boards
  alias Api.Boards.Board

  action_fallback ApiWeb.FallbackController

  def index(conn, _params) do
    with boards <- Boards.list_boards(),
         true <- is_list(boards) do
      render(conn, "index.json", boards: boards)
    else
      false ->
        conn
        |> put_status(:bad_request)
        |> render("error.json", message: "Cannot get the boards.")
    end
  end

  def create(conn, %{"board" => board_params}) do
    with {:ok, %Board{} = board} <- Boards.create_board(board_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.board_path(conn, :show, board))
      |> render("show.json", board: board)
    else
      {:error, reason} ->
        conn |> put_status(:bad_request) |> render("error.json", message: reason)
    end
  end

  def show(conn, %{"id" => id}) do
    with board <- Boards.get_board(id),
         true <- board != nil do
      render(conn, "show.json", board: board)
    else
      false ->
        conn
        |> put_status(:bad_request)
        |> render("error.json", message: "Cannot find the board.")
    end
  end

  def update(conn, %{"id" => id, "board" => board_params}) do
    with board <- Boards.get_board(id),
         true <- board != nil,
         {:ok, %Board{} = board} <- Boards.update_board(board, board_params) do
      render(conn, "show.json", board: board)
    else
      false ->
        conn
        |> put_status(:bad_request)
        |> render("error.json", message: "Cannot find the board.")

      {:error, _reason} ->
        conn
        |> put_status(:bad_request)
        |> render("error.json", message: "Cannot update the board.")
    end
  end

  def delete(conn, %{"id" => id}) do
    with board <- Boards.get_board(id),
         true <- board != nil,
         {:ok, %Board{}} <- Boards.delete_board(board) do
      render(conn, "delete.json", message: "'#{board.title}' has been deleted.")
    else
      false ->
        conn
        |> put_status(:bad_request)
        |> render("error.json", message: "Cannot find the board.")

      {:error, _reason} ->
        conn
        |> put_status(:bad_request)
        |> render("error.json", message: "Cannot delete the board.")
    end
  end
end
