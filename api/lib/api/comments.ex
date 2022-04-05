defmodule Api.Comments do
  @moduledoc """
  The Comments context.
  """

  import Ecto.Query, warn: false
  alias Api.Repo

  alias Api.Tasks.Task
  alias Api.Comments.Comment

  @doc """
  Returns the list of comments.

  ## Examples

      iex> list_comments(task_id)
      {:ok, [%Comment{}, ...]}

  """
  def list_comments(task_id) do
    try do
      comments =
        Repo.all(
          from comment in Comment,
            where: comment.task_id == ^task_id,
            select: comment
        )

      {:ok, comments}
    catch
      _ -> {:error, "Cannot get the comments."}
    end
  end

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment(task_id, 123)
      {:ok, %Comment{}}

      iex> get_comment(456)
      ** {:not_found, "Comment not found."}

  """
  def get_comment(task_id, comment_id) do
    with {:ok, comments} <- list_comments(task_id),
         comment <- Enum.find(comments, &(&1.id == comment_id)),
         true <- comment != nil do
      {:ok, comment}
    else
      _ -> {:not_found, "Comment not found."}
    end
  end

  @doc """
  Creates a comment.

  ## Examples

      iex> create_comment(task, %{field: value})
      {:ok, %Comment{}}

      iex> create_comment(task, %{field: bad_value})
      {:error, "Cannot create the comment."}

  """
  def create_comment(%Task{} = task, attrs \\ %{}) do
    with {:ok, comment} <-
           task
           |> Ecto.build_assoc(:comments)
           |> Comment.changeset(attrs)
           |> Repo.insert() do
      {:ok, comment}
    else
      _ -> {:error, "Cannot create the comment."}
    end
  end

  @doc """
  Updates a comment.

  ## Examples

      iex> update_comment(comment, %{field: new_value})
      {:ok, %Comment{}}

      iex> update_comment(comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_comment(%Comment{} = comment, attrs) do
    with {:ok, updated_comment} <-
           comment
           |> Comment.changeset(attrs)
           |> Repo.update() do
      {:ok, updated_comment}
    else
      {:error, _} -> {:error, "Cannot update the comment."}
    end
  end

  @doc """
  Deletes a comment.

  ## Examples

      iex> delete_comment(comment)
      {:ok, %Comment{}}

      iex> delete_comment(comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment(%Comment{} = comment) do
    with {:ok, comment} <- Repo.delete(comment) do
      {:ok, "'#{comment.description}' comment is deleted."}
    else
      {:error, _reason} -> {:error, "Cannot delete the comment."}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{data: %Comment{}}

  """
  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end
end
