defmodule ClientWeb.TaskLive.TaskFormComponent do
  use ClientWeb, :live_component

  alias Client.Comments
  alias Client.Comments.Comment
  alias Client.Tasks
  alias Client.Tasks.Task

  alias Ecto.Changeset

  @impl true
  def update(%{resource: "task"} = assigns, socket) do
    task_changeset =
      Changeset.cast(
        %Task{
          user_id: assigns.user_id,
          title: assigns.task.title,
          description: assigns.task.description,
          order: assigns.task.order,
          status: assigns.task.status
        },
        %{},
        [
          :user_id,
          :title,
          :description,
          :order,
          :status
        ]
      )

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, task_changeset)}
  end

  @impl true
  def update(%{resource: "comment"} = assigns, socket) do
    IO.inspect(assigns)

    comment_changeset =
      Changeset.cast(
        %Comment{
          user_id: assigns.user_id,
          description: assigns.comment.description
        },
        %{},
        [
          :user_id,
          :description
        ]
      )

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, comment_changeset)}
  end

  @impl true
  def handle_event("save_task", %{"task" => task_params}, socket) do
    save_task(socket, socket.assigns.action, task_params)
  end

  @impl true
  def handle_event("save_comment", %{"comment" => comment_params}, socket) do
    save_comment(socket, socket.assigns.action, comment_params)
  end

  defp save_task(socket, :edit, task_params) do
    with true <- task_params["order"] != "",
         {:ok, _todo} <-
           Tasks.update_task(
             socket.assigns.token,
             socket.assigns.board_id,
             socket.assigns.list_id,
             socket.assigns.task_id,
             %{
               task: %{
                 title: task_params["title"],
                 description: task_params["description"],
                 order: task_params["order"] |> String.to_integer(),
                 status: task_params["status"],
                 user_id: task_params["user_id"] |> String.to_integer()
               }
             }
           ) do
      {:noreply,
       socket
       |> put_flash(:info, "Task updated successfully.")
       |> push_redirect(
         to:
           "/boards/#{socket.assigns.board_id}/lists/#{socket.assigns.list_id}/tasks/#{socket.assigns.task_id}/index"
       )}
    else
      false ->
        {:noreply,
         socket
         |> put_flash(:error, "Order should not be empty.")
         |> push_redirect(
           to:
             "/boards/#{socket.assigns.board_id}/lists/#{socket.assigns.list_id}/tasks/#{socket.assigns.task_id}/index"
         )}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "#{reason["error"]}")
         |> push_redirect(
           to:
             "/boards/#{socket.assigns.board_id}/lists/#{socket.assigns.list_id}/tasks/#{socket.assigns.task_id}/index"
         )}
    end
  end

  defp save_comment(socket, :new, comment_params) do
    with {:ok, _task_item} <-
           Comments.create_comment(
             socket.assigns.token,
             socket.assigns.board_id,
             socket.assigns.list_id,
             socket.assigns.task_id,
             %{
               comment: %{
                 description: comment_params["description"]
               }
             }
           ) do
      {:noreply,
       socket
       |> put_flash(:info, "Comment created successfully.")
       |> push_redirect(
         to:
           "/boards/#{socket.assigns.board_id}/lists/#{socket.assigns.list_id}/tasks/#{socket.assigns.task_id}/index"
       )}
    else
      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "#{reason["error"]}")
         |> push_redirect(
           to:
             "/boards/#{socket.assigns.board_id}/lists/#{socket.assigns.list_id}/tasks/#{socket.assigns.task_id}/index"
         )}
    end
  end

  defp save_comment(socket, :edit, comment_params) do
    IO.inspect(socket.assigns)
    IO.inspect(comment_params)

    with {:ok, _comment} <-
           Comments.update_comment(
             socket.assigns.token,
             socket.assigns.board_id,
             socket.assigns.list_id,
             socket.assigns.task_id,
             socket.assigns.comment.id,
             %{
               comment: %{
                 description: comment_params["description"]
               }
             }
           ) do
      {:noreply,
       socket
       |> put_flash(:info, "Task updated successfully.")
       |> push_redirect(
         to:
           "/boards/#{socket.assigns.board_id}/lists/#{socket.assigns.list_id}/tasks/#{socket.assigns.task_id}/index"
       )}
    else
      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "#{reason["error"]}")
         |> push_redirect(
           to:
             "/boards/#{socket.assigns.board_id}/lists/#{socket.assigns.list_id}/tasks/#{socket.assigns.task_id}/index"
         )}
    end
  end
end
