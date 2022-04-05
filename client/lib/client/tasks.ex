defmodule Client.Tasks do
  use Tesla

  plug(Tesla.Middleware.BaseUrl, "http://localhost:4000/api")
  plug(Tesla.Middleware.JSON)

  alias Client.Helpers

  @moduledoc """
  The Tasks context.
  """

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks(token, board_id, list_id)
      {:ok, [%Task{}, ...]}

  """
  def list_tasks(token, board_id, list_id) do
    client = Tesla.client([{Tesla.Middleware.Headers, [{"authorization", token}]}])

    with {:ok, response} <-
           get(
             client,
             "/boards/#{board_id}/lists/#{list_id}/tasks"
           ) do
      case Map.has_key?(response.body, "data") do
        true ->
          {:ok, Helpers.recursive_keys_to_atom(response.body["data"])}

        false ->
          {:error, response.body["error"]}
      end
    else
      reason -> {:error, reason}
    end
  end

  @doc """
  Gets a single task.

  ## Examples

      iex> get_task(token, board_id, list_id, task_id)
      {:ok, %Task{}}

  """
  def get_task(token, board_id, list_id, task_id) do
    client = Tesla.client([{Tesla.Middleware.Headers, [{"authorization", token}]}])

    with {:ok, response} <-
           get(
             client,
             "/boards/#{board_id}/lists/#{list_id}/tasks/#{task_id}"
           ) do
      case Map.has_key?(response.body, "data") do
        true ->
          {:ok, Helpers.recursive_keys_to_atom(response.body["data"])}

        false ->
          {:error, response.body["error"]}
      end
    else
      reason -> {:error, reason}
    end
  end

  @doc """
  Creates a task.

  status: "not_started", "in_progress", "completed"

  ## Examples

      iex> create_task(token, board_id, list_id, %{task: %{title: "task title", order: 1, status: "not_started"}})
      {:ok, %Task{}}

  """
  def create_task(token, board_id, list_id, attrs \\ %{}) do
    client = Tesla.client([{Tesla.Middleware.Headers, [{"authorization", token}]}])

    with {:ok, response} <-
           post(
             client,
             "/boards/#{board_id}/lists/#{list_id}/tasks",
             attrs
           ) do
      case Map.has_key?(response.body, "data") do
        true ->
          {:ok, response.body["data"]}

        false ->
          {:error, response.body["error"]}
      end
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Updates a task.

  In case of inter-list movement of tasks, we need to indicate :old_list_id aside from the list_id.

  ## Examples

      iex> update_task(token, board_id, list_id, task_id, %{task: %{title: "updated task title"}})
      {:ok, %Task{}}

  """
  def update_task(token, board_id, list_id, task_id, task_body) do
    client = Tesla.client([{Tesla.Middleware.Headers, [{"authorization", token}]}])

    with {:ok, response} <-
           patch(
             client,
             "/boards/#{board_id}/lists/#{list_id}/tasks/#{task_id}",
             task_body
           ) do
      case Map.has_key?(response.body, "data") do
        true ->
          {:ok, response.body["data"]}

        false ->
          {:error, response.body["error"]}
      end
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Deletes a task.

  ## Examples

      iex> delete_task(token, board_id, list_id, task_id)
      {:ok, %Task{}}

  """
  def delete_task(token, board_id, list_id, task_id) do
    client = Tesla.client([{Tesla.Middleware.Headers, [{"authorization", token}]}])

    with {:ok, response} <-
           delete(
             client,
             "/boards/#{board_id}/lists/#{list_id}/tasks/#{task_id}"
           ) do
      case Map.has_key?(response.body, "data") do
        true ->
          {:ok, response.body["data"]}

        false ->
          {:error, response.body["error"]}
      end
    else
      {:error, reason} -> {:error, reason}
    end
  end
end
