defmodule ApiWeb.TaskView do
  use ApiWeb, :view
  alias ApiWeb.TaskView

  def render("index.json", %{tasks: tasks}) do
    %{data: render_many(tasks, TaskView, "task.json")}
  end

  def render("show.json", %{task: task}) do
    %{data: render_one(task, TaskView, "task.json")}
  end

  def render("task.json", %{task: task}) do
    %{
      id: task.id,
      title: task.title,
      description: task.description,
      order: task.order,
      status: task.status
    }
  end

  def render("delete.json", %{message: message}) do
    %{data: %{message: message}}
  end

  def render("error.json", %{error: error}) do
    %{error: %{error: error}}
  end
end
