defmodule ClientWeb.BoardLive.BoardFormComponent do
  use ClientWeb, :live_component

  alias Client.Lists
  alias Client.Lists.List
  alias Client.Tasks
  alias Client.Tasks.Task

  alias Ecto.Changeset

  @impl true
  def update(%{resource: "list"} = assigns, socket) do
    list_changeset =
      Changeset.cast(
        %List{
          user_id: assigns.user_id,
          title: assigns.list.title,
          order: assigns.list.order
        },
        %{},
        [
          :user_id,
          :title,
          :order
        ]
      )

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, list_changeset)}
  end

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
  def handle_event("save_list", %{"list" => list_params}, socket) do
    save_list(socket, socket.assigns.action, list_params)
  end

  @impl true
  def handle_event("save_task", %{"task" => task_params}, socket) do
    save_task(socket, socket.assigns.action, task_params)
  end

  defp save_list(socket, :new, list_params) do
    with true <- list_params["order"] != "",
         {:ok, _list_item} <-
           Lists.create_list(
             socket.assigns.token,
             socket.assigns.id,
             %{
               list: %{
                 title: list_params["title"],
                 order: list_params["order"] |> String.to_integer()
               }
             }
           ) do
      {:noreply,
       socket
       |> put_flash(:info, "List created successfully.")
       |> push_redirect(to: "/boards?id=#{socket.assigns.id}")}
    else
      false ->
        {:noreply,
         socket
         |> put_flash(:error, "Order should not be empty.")
         |> push_redirect(to: "/boards")}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "#{reason["error"]}")
         |> push_redirect(to: "/boards")}
    end
  end

  defp save_list(socket, :edit, list_params) do
    with true <- list_params["order"] != "",
         {:ok, _todo} <-
           Lists.update_list(
             socket.assigns.token,
             socket.assigns.id,
             socket.assigns.list.id,
             %{
               list: %{
                 title: list_params["title"],
                 order: list_params["order"] |> String.to_integer()
               }
             }
           ) do
      {:noreply,
       socket
       |> put_flash(:info, "List updated successfully.")
       |> push_redirect(to: "/boards?id=#{socket.assigns.id}")}
    else
      false ->
        {:noreply,
         socket
         |> put_flash(:error, "Order should not be empty.")
         |> push_redirect(to: "/boards")}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "#{reason["error"]}")
         |> push_redirect(to: "/boards")}
    end
  end

  defp save_task(socket, :new, task_params) do
    with true <- task_params["order"] != "",
         {:ok, _task_item} <-
           Tasks.create_task(
             socket.assigns.token,
             socket.assigns.board.id,
             socket.assigns.list.id,
             %{
               task: %{
                 title: task_params["title"],
                 description: task_params["description"],
                 order: task_params["order"] |> String.to_integer(),
                 status: task_params["status"]
               }
             }
           ) do
      {:noreply,
       socket
       |> put_flash(:info, "Task created successfully.")
       |> push_redirect(to: "/boards?id=#{socket.assigns.board.id}")}
    else
      false ->
        {:noreply,
         socket
         |> put_flash(:error, "Order should not be empty.")
         |> push_redirect(to: "/boards")}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "#{reason["error"]}")
         |> push_redirect(to: "/boards")}
    end
  end

  defp save_task(socket, :edit, task_params) do
    with true <- task_params["order"] != "",
         {:ok, _todo} <-
           Tasks.update_task(
             socket.assigns.token,
             socket.assigns.board.id,
             socket.assigns.list.id,
             socket.assigns.task.id,
             %{
               task: %{
                 title: task_params["title"],
                 description: task_params["description"],
                 order: task_params["order"] |> String.to_integer(),
                 status: task_params["status"]
               }
             }
           ) do
      {:noreply,
       socket
       |> put_flash(:info, "Task updated successfully.")
       |> push_redirect(to: "/boards?id=#{socket.assigns.board.id}")}
    else
      false ->
        {:noreply,
         socket
         |> put_flash(:error, "Order should not be empty.")
         |> push_redirect(to: "/boards")}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "#{reason["error"]}")
         |> push_redirect(to: "/boards")}
    end
  end
end
