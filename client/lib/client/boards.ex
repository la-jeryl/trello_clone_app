defmodule Client.Boards do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "http://localhost:4000/api"
  plug(Tesla.Middleware.JSON)

  alias Client.Helpers

  @moduledoc """
  The Boards context.
  """

  @doc """
  Returns the list of boards.

  ## Examples

      iex> list_board(token)
      {:ok, [%Board{}, ...]}

  """
  def list_boards(token) do
    client = Tesla.client([{Tesla.Middleware.Headers, [{"authorization", token}]}])

    with {:ok, response} <- get(client, "/boards") do
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
  Gets a single board.

  ## Examples

      iex> get_board(token,123)
      {:ok, %Board{}}

  """
  def get_board(token, board_id) do
    client = Tesla.client([{Tesla.Middleware.Headers, [{"authorization", token}]}])

    with {:ok, response} <- get(client, "/boards/#{board_id}") do
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
  Creates a board.

  ## Examples

      iex> create_list(token, %{board: %{title: "board title"}})
      {:ok, %Board{}}

  """
  def create_board(token, attrs \\ %{}) do
    client = Tesla.client([{Tesla.Middleware.Headers, [{"authorization", token}]}])

    with {:ok, response} <- post(client, "/boards", attrs) do
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
  Updates a board.

  ## Examples

      iex> update_board(token, board_id, %{board: %{title: "updated board title"}})
      {:ok, %Board{}}

  """
  def update_board(token, board_id, board_body) do
    client = Tesla.client([{Tesla.Middleware.Headers, [{"authorization", token}]}])

    with {:ok, response} <- patch(client, "/boards/#{board_id}", board_body) do
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
  Deletes a board.

  ## Examples

      iex> delete_board(token, board_id)
      {:ok, %Board{}}

  """
  def delete_board(token, board_id) do
    client = Tesla.client([{Tesla.Middleware.Headers, [{"authorization", token}]}])

    with {:ok, response} <- delete(client, "/boards/#{board_id}") do
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
