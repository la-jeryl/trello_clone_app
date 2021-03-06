defmodule ApiWeb.BoardView do
  use ApiWeb, :view
  alias ApiWeb.BoardView

  def render("index.json", %{boards: boards}) do
    %{data: render_many(boards, BoardView, "board.json")}
  end

  def render("show.json", %{board: board}) do
    %{data: render_one(board, BoardView, "board.json")}
  end

  def render("board.json", %{board: board}) do
    %{
      id: board.id,
      title: board.title,
      user_id: board.user_id
    }
  end

  def render("delete.json", %{message: message}) do
    %{data: %{message: message}}
  end

  def render("error.json", %{error: error}) do
    %{error: %{error: error}}
  end
end
