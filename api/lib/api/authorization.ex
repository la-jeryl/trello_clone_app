defmodule Api.Authorization do
  alias __MODULE__
  alias Api.Boards.Board
  alias Api.Lists.List
  alias Api.Tasks.Task
  alias Api.Comments.Comment
  defstruct role: nil, create: %{}, show: %{}, update: %{}, delete: %{}

  def can("read" = role) do
    grant(role)
    |> show(Board)
    |> show(List)
    |> show(Task)
    |> show(Comment)
    |> create(Comment)
  end

  def can("write" = role) do
    grant(role)
    |> show(Board)
    |> all(List)
    |> all(Task)
    |> all(Comment)
  end

  def can("manage" = role) do
    grant(role)
    |> all(Board)
    |> all(List)
    |> all(Task)
    |> all(Comment)
  end

  def grant(role), do: %Authorization{role: role}

  def show(authorization, resource), do: put_action(authorization, :show, resource)

  def create(authorization, resource), do: put_action(authorization, :create, resource)

  def update(authorization, resource), do: put_action(authorization, :update, resource)

  def delete(authorization, resource), do: put_action(authorization, :delete, resource)

  def all(authorization, resource) do
    authorization
    |> create(resource)
    |> show(resource)
    |> update(resource)
    |> delete(resource)
  end

  def show?(authorization, resource) do
    Map.get(authorization.show, resource, false)
  end

  def create?(authorization, resource) do
    Map.get(authorization.create, resource, false)
  end

  def update?(authorization, resource) do
    Map.get(authorization.update, resource, false)
  end

  def delete?(authorization, resource) do
    Map.get(authorization.delete, resource, false)
  end

  defp put_action(authorization, action, resource) do
    updated_action =
      authorization
      |> Map.get(action)
      |> Map.put(resource, true)

    Map.put(authorization, action, updated_action)
  end
end
