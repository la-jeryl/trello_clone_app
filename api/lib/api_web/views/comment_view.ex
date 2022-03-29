defmodule ApiWeb.CommentView do
  use ApiWeb, :view
  alias ApiWeb.CommentView

  def render("index.json", %{comments: comments}) do
    %{data: render_many(comments, CommentView, "comment.json")}
  end

  def render("show.json", %{comment: comment}) do
    %{data: render_one(comment, CommentView, "comment.json")}
  end

  def render("comment.json", %{comment: comment}) do
    %{
      id: comment.id,
      description: comment.description
    }
  end

  def render("delete.json", %{message: message}) do
    %{data: %{message: message}}
  end

  def render("error.json", %{error: error}) do
    %{error: %{error: error}}
  end
end
