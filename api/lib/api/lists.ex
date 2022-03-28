defmodule Api.Lists do
  @moduledoc """
  The Lists context.
  """

  import Ecto.Query, warn: false
  alias Api.Repo

  alias Api.Boards.Board
  alias Api.Lists.List
  alias Api.Helpers

  @doc """
  Returns the list of lists.

  ## Examples

      iex> list_lists(board_id)
      [%List{}, ...]

  """
  def list_lists(board_id) do
    try do
      lists =
        Repo.all(
          from list in List,
            where: list.board_id == ^board_id,
            select: list
        )
        |> Repo.preload(:tasks)

      sorted_lists = Enum.sort_by(lists, & &1.order, :asc)
      {:ok, sorted_lists}
    catch
      _ -> {:error, "Cannot get the lists."}
    end
  end

  @doc """
  Gets a single list.

  ## Examples

      iex> get_list(board_id, 123)
      {:ok, %List{}}

      iex> get_list(456)
      ** {:not_found, "List not found."}

  """
  def get_list(board_id, list_id) do
    with {:ok, lists} <- list_lists(board_id),
         list <- Enum.find(lists, &(&1.id == list_id)),
         true <- list != nil do
      {:ok, list}
    else
      _ -> {:not_found, "List not found."}
    end
  end

  @doc """
  Creates a list.

  ## Examples

      iex> create_list(board, %{field: value})
      {:ok, %List{}}

      iex> create_list(board, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_list(%Board{} = board, attrs \\ %{}) do
    result =
      with true <- Map.has_key?(attrs, :order),
           proposed_order_value <- Map.get(attrs, :order),
           true <- proposed_order_value != nil do
        # check if proposed order value is within valid range
        latest_lists_count = Enum.count(board.lists) + 1

        if proposed_order_value in 1..latest_lists_count do
          inserted_list =
            board
            |> Ecto.build_assoc(:lists)
            |> List.changeset(attrs)
            |> Repo.insert()

          {:ok, list_details} = inserted_list

          if proposed_order_value < latest_lists_count do
            arrange_lists(board, list_details, proposed_order_value, "create")
          end

          inserted_list
        else
          {:out_of_range, "Assigned 'order' is out of valid range."}
        end
      else
        _ ->
          updated_list_map =
            attrs
            |> Map.put(:order, Enum.count(board.lists) + 1)
            |> Helpers.key_to_atom()

          board
          |> Ecto.build_assoc(:lists)
          |> List.changeset(updated_list_map)
          |> Repo.insert()
      end

    # Could return {:ok, struct} or {:error, changeset}
    case result do
      {:ok, result} ->
        {:ok, result}

      {:out_of_range, reason} ->
        {:error, reason}

      {:error, _} ->
        {:error, "Cannot create the list."}
    end
  end

  @doc """
  Updates a list.

  ## Examples

      iex> update_list(board, list, %{field: new_value})
      {:ok, %List{}}

      iex> update_list(board, list, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_list(%Board{} = board, %List{} = list, attrs) do
    result =
      with true <- Map.has_key?(attrs, :order),
           proposed_order_value <- Map.get(attrs, :order),
           true <- proposed_order_value != nil do
        # check if proposed order value is within valid range
        if proposed_order_value in 1..Enum.count(board.lists) do
          arrange_lists(board, list, proposed_order_value, "update")

          list |> List.changeset(attrs) |> Repo.update()
        else
          {:out_of_range, "Assigned 'order' is out of valid range."}
        end
      else
        _ -> list |> List.changeset(attrs) |> Repo.update()
      end

    case result do
      {:ok, result} -> {:ok, result}
      {:out_of_range, reason} -> {:error, reason}
      {:error, _} -> {:error, "Cannot update the list."}
    end
  end

  @doc """
  Deletes a list.

  ## Examples

      iex> delete_list(board,list)
      {:ok, %List{}}

      iex> delete_list(board,list)
      {:error, %Ecto.Changeset{}}

  """
  def delete_list(%Board{} = board, %List{} = list) do
    with {:ok, deleted_list} <- Repo.delete(list) do
      arrange_lists(board, list, nil, "delete")
      {:ok, "'#{deleted_list.title}' list is deleted."}
    else
      {:error, _reason} -> {:error, "Cannot delete the list."}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking list changes.

  ## Examples

      iex> change_list(list)
      %Ecto.Changeset{data: %List{}}

  """
  def change_list(%List{} = list, attrs \\ %{}) do
    List.changeset(list, attrs)
  end

  ######################################################################

  defp arrange_lists(%Board{} = board, %List{} = list, proposed_order_value, action_type) do
    case action_type do
      "create" ->
        board.lists
        |> Enum.sort_by(& &1.order, :asc)
        |> custom_sort(proposed_order_value)

      "update" ->
        Enum.filter(board.lists, &(&1.id != list.id))
        |> Enum.sort_by(& &1.order, :asc)
        |> custom_sort(proposed_order_value)

      "delete" ->
        Enum.filter(board.lists, &(&1.id != list.id))
        |> Enum.sort_by(& &1.order, :asc)
        |> reset_list_order()
    end
  end

  defp custom_sort(sorted_list, proposed_order_value) do
    # split the list based on the item to be replaced
    first_half = Enum.split(sorted_list, proposed_order_value - 1) |> elem(0)
    second_half = Enum.split(sorted_list, proposed_order_value - 1) |> elem(1)

    # update the order on the second half starting on index 1
    reset_list_order(first_half)

    # update the order on the second half starting on the proposed_order_value + 1
    reset_list_order(second_half, proposed_order_value + 1)
  end

  defp reset_list_order(list, custom_index \\ 1) do
    list
    |> Enum.with_index(custom_index)
    |> Enum.map(fn {item, index} ->
      item
      |> List.changeset(%{order: index})
      |> Repo.update()
    end)
  end
end
