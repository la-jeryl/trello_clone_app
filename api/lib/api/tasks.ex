defmodule Api.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias Api.Repo

  alias Api.Tasks.Task
  alias Api.Lists.List
  alias Api.Helpers

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks(list_id)
     {:ok, [%Task{}, ...]}

  """
  def list_tasks(list_id) do
    try do
      tasks =
        Repo.all(
          from task in Task,
            where: task.list_id == ^list_id,
            select: task
        )

      sorted_tasks = Enum.sort_by(tasks, & &1.order, :asc)
      {:ok, sorted_tasks}
    catch
      _ -> {:error, "Cannot get the tasks."}
    end
  end

  @doc """
  Gets a single task.

  ## Examples

      iex> get_task(list_id, 123)
      %Task{}

      iex> get_task(list_id, 456)
      ** (Ecto.NoResultsError)

  """
  def get_task(list_id, task_id) do
    with {:ok, tasks} <- list_tasks(list_id),
         task <- Enum.find(tasks, &(&1.id == task_id)),
         true <- task != nil do
      {:ok, task}
    else
      _ -> {:not_found, "Task not found."}
    end
  end

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(list, %{field: value})
      {:ok, %Task{}}

      iex> create_task(list, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task(%List{} = list, attrs \\ %{}) do
    result =
      with true <- Map.has_key?(attrs, :order),
           proposed_order_value <- Map.get(attrs, :order),
           true <- proposed_order_value != nil do
        # check if proposed order value is within valid range
        latest_tasks_count = Enum.count(list.tasks) + 1

        if proposed_order_value in 1..latest_tasks_count do
          case valid_status(attrs) do
            {:ok, _message} ->
              inserted_task =
                list
                |> Ecto.build_assoc(:tasks)
                |> Task.changeset(attrs)
                |> Repo.insert()

              {:ok, task_details} = inserted_task

              if proposed_order_value < latest_tasks_count do
                arrange_tasks(list, task_details, proposed_order_value, "create")
              end

              inserted_task

            {:invalid_status, reason} ->
              {:invalid_status, reason}
          end
        else
          {:out_of_range, "Assigned 'order' is out of valid range."}
        end
      else
        _ ->
          case valid_status(attrs) do
            {:ok, _message} ->
              updated_task_map =
                attrs
                |> Map.put(:order, Enum.count(list.tasks) + 1)
                |> Helpers.key_to_atom()

              list
              |> Ecto.build_assoc(:tasks)
              |> Task.changeset(updated_task_map)
              |> Repo.insert()

            {:invalid_status, reason} ->
              {:invalid_status, reason}
          end
      end

    # Could return {:ok, struct} or {:error, changeset}
    case result do
      {:ok, result} ->
        {:ok, result}

      {:out_of_range, reason} ->
        {:error, reason}

      {:invalid_status, reason} ->
        {:error, reason}

      {:error, _} ->
        {:error, "Cannot create the task."}
    end
  end

  @doc """
  Updates a task.

  ## Examples

      iex> update_task(list, task, %{field: new_value})
      {:ok, %Task{}}

      iex> update_task(list, task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_task(%List{} = list, %Task{} = task, attrs) do
    result =
      with true <- Map.has_key?(attrs, :order),
           proposed_order_value <- Map.get(attrs, :order),
           true <- proposed_order_value != nil do
        # check if proposed order value is within valid range
        if proposed_order_value in 1..Enum.count(list.tasks) do
          case valid_status(attrs) do
            {:ok, _message} ->
              arrange_tasks(list, task, proposed_order_value, "update")

              task |> Task.changeset(attrs) |> Repo.update()

            {:invalid_status, reason} ->
              {:invalid_status, reason}
          end
        else
          {:out_of_range, "Assigned 'order' is out of valid range."}
        end
      else
        _ ->
          case valid_status(attrs) do
            {:ok, _message} ->
              task |> Task.changeset(attrs) |> Repo.update()

            {:invalid_status, reason} ->
              {:invalid_status, reason}
          end
      end

    case result do
      {:ok, result} ->
        {:ok, result}

      {:out_of_range, reason} ->
        {:error, reason}

      {:invalid_status, reason} ->
        {:error, reason}

      {:error, _} ->
        {:error, "Cannot update the task."}
    end
  end

  @doc """
  Deletes a task.

  ## Examples

      iex> delete_task(task)
      {:ok, %Task{}}

      iex> delete_task(task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task(%List{} = list, %Task{} = task) do
    with {:ok, deleted_task} <- Repo.delete(task) do
      arrange_tasks(list, task, nil, "delete")
      {:ok, "'#{deleted_task.title}' task is deleted."}
    else
      {:error, _reason} -> {:error, "Cannot delete the tas."}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.

  ## Examples

      iex> change_task(task)
      %Ecto.Changeset{data: %Task{}}

  """
  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  ######################################################################

  defp arrange_tasks(%List{} = list, %Task{} = task, proposed_order_value, action_type) do
    case action_type do
      "create" ->
        list.tasks
        |> Enum.sort_by(& &1.order, :asc)
        |> custom_sort(proposed_order_value)

      "update" ->
        Enum.filter(list.tasks, &(&1.id != task.id))
        |> Enum.sort_by(& &1.order, :asc)
        |> custom_sort(proposed_order_value)

      "delete" ->
        Enum.filter(list.tasks, &(&1.id != task.id))
        |> Enum.sort_by(& &1.order, :asc)
        |> reset_task_order()
    end
  end

  defp custom_sort(sorted_task, proposed_order_value) do
    # split the task based on the item to be replaced
    first_half = Enum.split(sorted_task, proposed_order_value - 1) |> elem(0)
    second_half = Enum.split(sorted_task, proposed_order_value - 1) |> elem(1)

    # update the order on the second half starting on index 1
    reset_task_order(first_half)

    # update the order on the second half starting on the proposed_order_value + 1
    reset_task_order(second_half, proposed_order_value + 1)
  end

  defp reset_task_order(task, custom_index \\ 1) do
    task
    |> Enum.with_index(custom_index)
    |> Enum.map(fn {item, index} ->
      item
      |> Task.changeset(%{order: index})
      |> Repo.update()
    end)
  end

  defp valid_status(task_params) do
    valid_status = [
      "not_started",
      "in_progress",
      "completed",
      :not_started,
      :in_progress,
      :completed
    ]

    case Enum.member?(valid_status, task_params.status) do
      true ->
        {:ok, "Valid task status."}

      false ->
        {:invalid_status, "Invalid task status."}
    end
  end
end
