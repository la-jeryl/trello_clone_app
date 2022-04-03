defmodule ApiWeb.TaskController do
  use ApiWeb, :controller

  alias Api.Tasks
  alias Api.Lists
  alias Api.Tasks.Task
  alias Api.Helpers

  action_fallback ApiWeb.FallbackController

  plug ApiWeb.Authorize, resource: Api.Tasks.Task

  def index(conn, %{"list_id" => list_id}) do
    with {:ok, sorted_tasks} <- Tasks.list_tasks(list_id) do
      render(conn, "index.json", tasks: sorted_tasks)
    else
      {_, reason} ->
        conn |> put_status(:bad_request) |> render("error.json", error: reason)
    end
  end

  def create(conn, %{"board_id" => board_id, "list_id" => list_id, "task" => task_params}) do
    updated_task_params =
      task_params |> Helpers.key_to_atom() |> Map.put(:user_id, conn.assigns.current_user.id)

    with {:ok, list} <- Lists.get_list(numeric(board_id), numeric(list_id)),
         {:ok, %Task{} = task} <- Tasks.create_task(list, updated_task_params) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        Routes.board_list_task_path(conn, :show, board_id, list_id, task)
      )
      |> render("show.json", task: task)
    else
      {_, reason} ->
        conn |> put_status(:bad_request) |> render("error.json", error: reason)
    end
  end

  def show(conn, %{"list_id" => list_id, "id" => id}) do
    with {:ok, %Task{} = task} <- Tasks.get_task(numeric(list_id), numeric(id)) do
      render(conn, "show.json", task: task)
    else
      {_, reason} ->
        conn |> put_status(:bad_request) |> render("error.json", error: reason)
    end
  end

  def update(conn, %{
        "board_id" => board_id,
        "list_id" => list_id,
        "id" => id,
        "task" => task_params
      }) do
    updated_task_params =
      task_params |> Helpers.key_to_atom() |> Map.put(:user_id, conn.assigns.current_user.id)

    with {:ok, list} <- Lists.get_list(numeric(board_id), numeric(list_id)),
         {:ok, task} <- Tasks.get_task(numeric(list_id), numeric(id)),
         {:ok, %Task{} = task} <- Tasks.update_task(list, task, updated_task_params) do
      render(conn, "show.json", task: task)
    else
      {_, reason} ->
        conn |> put_status(:bad_request) |> render("error.json", error: reason)
    end
  end

  def delete(conn, %{"board_id" => board_id, "list_id" => list_id, "id" => id}) do
    with {:ok, list} <- Lists.get_list(numeric(board_id), numeric(list_id)),
         {:ok, task} <- Tasks.get_task(numeric(list_id), numeric(id)),
         {:ok, message} <- Tasks.delete_task(list, task) do
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
