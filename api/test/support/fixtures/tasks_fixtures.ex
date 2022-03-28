defmodule Api.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Api.Tasks` context.
  """

  @doc """
  Generate a task.
  """
  def task_fixture(user_id, list) do
    params = %{
      description: "some description",
      order: 1,
      status: :not_started,
      title: "some title",
      user_id: user_id
    }

    {:ok, task} = Api.Tasks.create_task(list, params)

    task
  end
end
