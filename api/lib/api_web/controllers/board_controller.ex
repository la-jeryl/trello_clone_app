defmodule ApiWeb.BoardController do
  use ApiWeb, :controller

  alias Api.Boards
  alias Api.Boards.Board
  alias Api.Helpers

  action_fallback ApiWeb.FallbackController

  plug ApiWeb.Authorize, resource: Api.Boards.Board

  def index(conn, _params) do
    with {:ok, boards} <- Boards.list_boards() do
      render(conn, "index.json", boards: boards)
    else
      {:error, reason} ->
        conn |> put_status(:bad_request) |> render("error.json", error: reason)
    end
  end

  def create(conn, %{"board" => board_params}) do
    updated_params =
      board_params |> Helpers.key_to_atom() |> Map.put(:user_id, conn.assigns.current_user.id)

    with {:ok, %Board{} = board} <- Boards.create_board(updated_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.board_path(conn, :show, board))
      |> render("show.json", board: board)
    else
      {_, reason} ->
        conn |> put_status(:bad_request) |> render("error.json", error: reason)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, board} <- Boards.get_board(id) do
      render(conn, "show.json", board: board)
    else
      {_, reason} ->
        conn |> put_status(:bad_request) |> render("error.json", error: reason)
    end
  end

  def update(conn, %{"id" => id, "board" => board_params}) do
    updated_params =
      board_params |> Helpers.key_to_atom() |> Map.put(:user_id, conn.assigns.current_user.id)

    with {:ok, board} <- Boards.get_board(id),
         {:ok, %Board{} = board} <- Boards.update_board(board, updated_params) do
      render(conn, "show.json", board: board)
    else
      {_, reason} ->
        conn |> put_status(:bad_request) |> render("error.json", error: reason)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, board} <- Boards.get_board(id),
         {:ok, message} <- Boards.delete_board(board) do
      render(conn, "delete.json", message: message)
    else
      {_, reason} ->
        conn |> put_status(:bad_request) |> render("error.json", error: reason)
    end
  end
end
