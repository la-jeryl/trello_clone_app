defmodule Api.Boards do
  @moduledoc """
  The Boards context.
  """

  import Ecto.Query, warn: false
  alias Api.Repo

  alias Api.Boards.Board

  @doc """
  Returns the list of boards.

  ## Examples

      iex> list_boards()
      [%Board{}, ...]

  """
  def list_boards do
    try do
      boards =
        Board
        |> Repo.all()
        |> Repo.preload(:lists)

      {:ok, boards}
    catch
      _ -> {:error, "Cannot get the boards."}
    end
  end

  @doc """
  Gets a single board.

  Raises `Ecto.NoResultsError` if the Board does not exist.

  ## Examples

      iex> get_board(123)
      %Board{}

      iex> get_board(456)
      ** (Ecto.NoResultsError)

  """
  def get_board(id) do
    case Board |> Repo.get(id) |> Repo.preload(:lists) do
      nil -> {:not_found, "Board not found"}
      board -> {:ok, board}
    end
  end

  @doc """
  Creates a board.

  ## Examples

      iex> create_board(%{field: value})
      {:ok, %Board{}}

      iex> create_board(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_board(attrs \\ %{}) do
    %Board{}
    |> Board.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, %Board{} = board} -> {:ok, Repo.preload(board, :lists)}
      _ -> {:error, "Cannot create the board."}
    end
  end

  @doc """
  Updates a board.

  ## Examples

      iex> update_board(board, %{field: new_value})
      {:ok, %Board{}}

      iex> update_board(board, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_board(%Board{} = board, attrs) do
    with {:ok, updated_board} <-
           board
           |> Board.changeset(attrs)
           |> Repo.update() do
      {:ok, updated_board}
    else
      {:error, _} -> {:error, "Cannot update the board."}
    end
  end

  @doc """
  Deletes a board.

  ## Examples

      iex> delete_board(board)
      {:ok, %Board{}}

      iex> delete_board(board)
      {:error, %Ecto.Changeset{}}

  """
  def delete_board(%Board{} = board) do
    with {:ok, board} <- Repo.delete(board) do
      {:ok, "'#{board.title}' board is deleted."}
    else
      {:error, _reason} -> {:error, "Cannot delete the board."}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking board changes.

  ## Examples

      iex> change_board(board)
      %Ecto.Changeset{data: %Board{}}

  """
  def change_board(%Board{} = board, attrs \\ %{}) do
    Board.changeset(board, attrs)
  end
end
