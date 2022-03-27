defmodule ApiWeb.ListController do
  use ApiWeb, :controller

  alias Api.Boards
  alias Api.Lists
  alias Api.Lists.List
  alias Api.Helpers

  action_fallback ApiWeb.FallbackController

  def index(conn, %{"board_id" => board_id}) do
    with {:ok, board} <- Boards.get_board(board_id) do
      render(conn, "index.json", lists: board.lists)
    else
      {_, reason} ->
        conn |> put_status(:bad_request) |> render("error.json", error: reason)
    end
  end

  def create(conn, %{"board_id" => board_id, "list" => list_params}) do
    with {:ok, board} <- board_id |> numeric |> Boards.get_board(),
         {:ok, %List{} = list} <- Lists.create_list(board, Helpers.key_to_atom(list_params)) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.board_list_path(conn, :show, board_id, list))
      |> render("show.json", list: list)
    else
      {_, reason} ->
        conn |> put_status(:bad_request) |> render("error.json", error: reason)
    end
  end

  def show(conn, %{"board_id" => board_id, "id" => id}) do
    with {:ok, board} <- board_id |> numeric |> Boards.get_board(),
         {:ok, %List{} = list} <- Lists.get_list(board, numeric(id)) do
      render(conn, "show.json", list: list)
    else
      {_, reason} ->
        conn |> put_status(:bad_request) |> render("error.json", error: reason)
    end
  end

  def update(conn, %{"board_id" => board_id, "id" => id, "list" => list_params}) do
    with {:ok, board} <- board_id |> numeric |> Boards.get_board(),
         {:ok, list} <- Lists.get_list(board, numeric(id)),
         {:ok, %List{} = list} <- Lists.update_list(board, list, Helpers.key_to_atom(list_params)) do
      render(conn, "show.json", list: list)
    else
      {_, reason} ->
        conn |> put_status(:bad_request) |> render("error.json", error: reason)
    end
  end

  def delete(conn, %{"board_id" => board_id, "id" => id}) do
    with {:ok, board} <- board_id |> numeric |> Boards.get_board(),
         {:ok, list} <- Lists.get_list(board, numeric(id)),
         {:ok, message} <- Lists.delete_list(board, list) do
      render(conn, "delete.json", message: message)
    else
      {_, reason} ->
        conn |> put_status(:bad_request) |> render("error.json", error: reason)
    end
  end

  defp numeric(value) do
    case is_binary(value) do
      true -> String.to_integer(value)
      false -> value
    end
  end
end
