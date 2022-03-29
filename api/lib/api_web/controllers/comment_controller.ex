defmodule ApiWeb.CommentController do
  use ApiWeb, :controller

  alias Api.Tasks
  alias Api.Comments
  alias Api.Comments.Comment

  alias Api.Helpers

  action_fallback ApiWeb.FallbackController

  plug ApiWeb.Authorize, resource: Api.Boards.Board
  plug ApiWeb.Authorize, resource: Api.Lists.List
  plug ApiWeb.Authorize, resource: Api.Tasks.Task
  plug ApiWeb.Authorize, resource: Api.Comments.Comment

  def index(conn, %{"task_id" => task_id}) do
    with {:ok, comments} <- Comments.list_comments(task_id) do
      render(conn, "index.json", comments: comments)
    else
      {_, reason} ->
        conn |> put_status(:bad_request) |> render("error.json", error: reason)
    end
  end

  def create(conn, %{
        "board_id" => board_id,
        "list_id" => list_id,
        "task_id" => task_id,
        "comment" => comment_params
      }) do
    updated_comment_params =
      comment_params |> Helpers.key_to_atom() |> Map.put(:user_id, conn.assigns.current_user.id)

    with {:ok, task} <- Tasks.get_task(numeric(list_id), numeric(task_id)),
         {:ok, %Comment{} = comment} <- Comments.create_comment(task, updated_comment_params) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        Routes.board_list_task_comment_path(conn, :show, board_id, list_id, task_id, comment)
      )
      |> render("show.json", comment: comment)
    else
      {_, reason} ->
        conn |> put_status(:bad_request) |> render("error.json", error: reason)
    end
  end

  def show(conn, %{"task_id" => task_id, "id" => id}) do
    with {:ok, %Comment{} = comment} <- Comments.get_comment(numeric(task_id), numeric(id)) do
      render(conn, "show.json", comment: comment)
    else
      {_, reason} ->
        conn |> put_status(:bad_request) |> render("error.json", error: reason)
    end
  end

  def update(conn, %{
        "task_id" => task_id,
        "id" => id,
        "comment" => comment_params
      }) do
    with {:ok, %Comment{} = comment} <- Comments.get_comment(numeric(task_id), numeric(id)),
         {:ok, %Comment{} = updated_comment} <- Comments.update_comment(comment, comment_params) do
      render(conn, "show.json", comment: updated_comment)
    else
      {_, reason} ->
        conn |> put_status(:bad_request) |> render("error.json", error: reason)
    end
  end

  def delete(conn, %{"task_id" => task_id, "id" => id}) do
    with {:ok, %Comment{} = comment} <- Comments.get_comment(numeric(task_id), numeric(id)),
         {:ok, message} <- Comments.delete_comment(comment) do
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
