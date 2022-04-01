defmodule Client.Comments do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "http://localhost:4000/api"
  plug(Tesla.Middleware.JSON)

  alias Client.Helpers

  @moduledoc """
  The Comments context.
  """

  @doc """
  Returns the list of comments.

  ## Examples

      iex> list_comments(token, board_id, list_id, task_id)
      {:ok, [%Comment{}, ...]}

  """
  def list_comments(token, board_id, list_id, task_id) do
    client = Tesla.client([{Tesla.Middleware.Headers, [{"authorization", token}]}])

    with {:ok, response} <-
           get(
             client,
             "/boards/#{String.to_integer(board_id)}/lists/#{String.to_integer(list_id)}/tasks/#{String.to_integer(task_id)}/comments"
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
  Gets a single comment.

  ## Examples

      iex> get_comment(token, board_id, list_id, task_id, comment_id)
      {:ok, %Comment{}}

  """
  def get_comment(token, board_id, list_id, task_id, comment_id) do
    client = Tesla.client([{Tesla.Middleware.Headers, [{"authorization", token}]}])

    with {:ok, response} <-
           get(
             client,
             "/boards/#{String.to_integer(board_id)}/lists/#{String.to_integer(list_id)}/tasks/#{String.to_integer(task_id)}/comments/#{String.to_integer(comment_id)}"
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
  Creates a comment.

  ## Examples

      iex> create_task(token, board_id, list_id, task_id, %{comment: %{description: "this is a comment"}})
      {:ok, %Comment{}}

  """
  def create_comment(token, board_id, list_id, task_id, attrs \\ %{}) do
    client = Tesla.client([{Tesla.Middleware.Headers, [{"authorization", token}]}])

    with {:ok, response} <-
           post(
             client,
             "/boards/#{String.to_integer(board_id)}/lists/#{String.to_integer(list_id)}/tasks/#{String.to_integer(task_id)}/comments",
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
  Updates a comment.

  ## Examples

      iex> update_comment(token, board_id, list_id, task_id, comment_id, %{comment: %{description: "updated comment"}})
      {:ok, %Comment{}}

  """
  def update_comment(token, board_id, list_id, task_id, comment_id, comment_body) do
    client = Tesla.client([{Tesla.Middleware.Headers, [{"authorization", token}]}])

    with {:ok, response} <-
           patch(
             client,
             "/boards/#{String.to_integer(board_id)}/lists/#{String.to_integer(list_id)}/tasks/#{String.to_integer(task_id)}/comments/#{String.to_integer(comment_id)}",
             comment_body
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
  Deletes a comment.

  ## Examples

      iex> delete_task(token, board_id, list_id, task_id, comment_id)
      {:ok, %Comment{}}

  """
  def delete_comment(token, board_id, list_id, task_id, comment_id) do
    client = Tesla.client([{Tesla.Middleware.Headers, [{"authorization", token}]}])

    with {:ok, response} <-
           delete(
             client,
             "/boards/#{String.to_integer(board_id)}/lists/#{String.to_integer(list_id)}/tasks/#{String.to_integer(task_id)}/comments/#{String.to_integer(comment_id)}"
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
