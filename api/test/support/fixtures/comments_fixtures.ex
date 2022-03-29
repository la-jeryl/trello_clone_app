defmodule Api.CommentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Api.Comments` context.
  """

  @doc """
  Generate a comment.
  """
  def comment_fixture(user_id, task) do
    params = %{
      description: "some description",
      user_id: user_id
    }

    {:ok, comment} = Api.Comments.create_comment(task, params)

    comment
  end
end
