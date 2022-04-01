defmodule Client.Lists do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "http://localhost:4000/api"
  plug(Tesla.Middleware.JSON)

  alias Client.Helpers

  @moduledoc """
  The Lists context.
  """

  @doc """
  Returns the list of lists.

  ## Examples

      iex> list_lists(token, board_id)
      {:ok, [%List{}, ...]}

  """
  def list_lists(token, board_id) do
    client = Tesla.client([{Tesla.Middleware.Headers, [{"authorization", token}]}])

    with {:ok, response} <- get(client, "/boards/#{String.to_integer(board_id)}/lists") do
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
  Gets a single list.

  ## Examples

      iex> get_list(token,board_id, list_id)
      {:ok, %List{}}

  """
  def get_list(token, board_id, list_id) do
    client = Tesla.client([{Tesla.Middleware.Headers, [{"authorization", token}]}])

    with {:ok, response} <-
           get(
             client,
             "/boards/#{String.to_integer(board_id)}/lists/#{String.to_integer(list_id)}"
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
  Creates a list.

  ## Examples

      iex> create_list(token, board_id, %{list: %{title: "list title", order: 1}})
      {:ok, %List{}}

  """
  def create_list(token, board_id, attrs \\ %{}) do
    client = Tesla.client([{Tesla.Middleware.Headers, [{"authorization", token}]}])

    with {:ok, response} <- post(client, "/boards/#{String.to_integer(board_id)}/lists", attrs) do
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
  Updates a list.

  ## Examples

      iex> update_list(token, board_id, list_id, %{list: %{title: "updated list title"}})
      {:ok, %List{}}

  """
  def update_list(token, board_id, list_id, list_body) do
    client = Tesla.client([{Tesla.Middleware.Headers, [{"authorization", token}]}])

    with {:ok, response} <-
           patch(
             client,
             "/boards/#{String.to_integer(board_id)}/lists/#{String.to_integer(list_id)}",
             list_body
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
  Deletes a list.

  ## Examples

      iex> delete_list(token, board_id, list_id)
      {:ok, %List{}}

  """
  def delete_list(token, board_id, list_id) do
    client = Tesla.client([{Tesla.Middleware.Headers, [{"authorization", token}]}])

    with {:ok, response} <-
           delete(
             client,
             "/boards/#{String.to_integer(board_id)}/lists/#{String.to_integer(list_id)}"
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
