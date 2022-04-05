defmodule ApiWeb.ListView do
  use ApiWeb, :view
  alias ApiWeb.ListView

  def render("index.json", %{lists: lists}) do
    %{data: render_many(lists, ListView, "list.json")}
  end

  def render("show.json", %{list: list}) do
    %{data: render_one(list, ListView, "list.json")}
  end

  def render("list.json", %{list: list}) do
    %{
      id: list.id,
      title: list.title,
      order: list.order,
      board_id: list.board_id,
      user_id: list.user_id
    }
  end

  def render("delete.json", %{message: message}) do
    %{data: %{message: message}}
  end

  def render("error.json", %{error: error}) do
    %{error: %{error: error}}
  end
end
