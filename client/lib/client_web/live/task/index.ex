defmodule ClientWeb.TaskLive.Index do
  use ClientWeb, :live_view

  alias Client.Comments
  alias Client.Comments.Comment
  alias Client.Tasks
  alias Client.Tasks.Task
  import ClientWeb.LiveHelpers

  @impl true
  def mount(
        %{"board_id" => board_id, "list_id" => list_id, "task_id" => task_id} = _params,
        session,
        socket
      ) do
    with {:ok, task} <- Tasks.get_task(session["user_token"], board_id, list_id, task_id),
         {:ok, comments} <-
           Comments.list_comments(session["user_token"], board_id, list_id, task_id) do
      socket =
        socket
        |> assign(:token, session["user_token"])
        |> assign(:user_id, session["current_user"]["id"])
        |> assign(:boards, session["boards"])
        |> assign(:board_id, board_id)
        |> assign(:list_id, list_id)
        |> assign(:task_id, task_id)
        |> assign(:task, task)
        |> assign(:comments, comments)

      {:ok, socket}
    else
      {:error, reason} ->
        case Map.has_key?(reason, "code") do
          true ->
            {:ok,
             socket
             |> assign(:board_id, board_id)
             |> assign(:list_id, list_id)
             |> assign(:task_id, task_id)
             |> assign(:task, nil)
             |> assign(:comments, nil)
             |> put_flash(:error, "#{reason["message"]}")
             |> redirect(to: Routes.session_path(socket, :new))}

          false ->
            {:ok,
             socket
             |> put_flash(:error, reason["error"])
             |> redirect(to: Routes.session_path(socket, :new))}
        end
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"resource" => "task"} = params) do
    %{"board_id" => board_id, "list_id" => list_id, "task_id" => task_id} = params

    with {:ok, task} <- Tasks.get_task(socket.assigns.token, board_id, list_id, task_id) do
      socket
      |> assign(:resource, "task")
      |> assign(:title, "Edit Task")
      |> assign(:task, task)
      |> assign(:comment, %Comment{})
    else
      {:error, reason} ->
        case Map.has_key?(reason, "code") do
          true ->
            socket
            |> assign(:resource, "task")
            |> assign(:title, "Edit Task")
            |> assign(:task, nil)
            |> assign(:comment, nil)
            |> put_flash(:error, "#{reason["message"]}")
            |> push_redirect(
              to:
                "/boards/#{socket.assigns.board_id}/lists/#{socket.assigns.list_id}/tasks/#{socket.assigns.task_id}/index"
            )

          false ->
            socket
            |> put_flash(:error, reason["error"])
            |> push_redirect(
              to:
                "/boards/#{socket.assigns.board_id}/lists/#{socket.assigns.list_id}/tasks/#{socket.assigns.task_id}/index"
            )
        end
    end
  end

  defp apply_action(socket, :edit, %{"resource" => "comment"} = params) do
    %{
      "board_id" => board_id,
      "list_id" => list_id,
      "task_id" => task_id,
      "comment_id" => comment_id
    } = params

    with {:ok, task} <- Tasks.get_task(socket.assigns.token, board_id, list_id, task_id),
         {:ok, comment} <-
           Comments.get_comment(socket.assigns.token, board_id, list_id, task_id, comment_id) do
      socket
      |> assign(:resource, "comment")
      |> assign(:title, "Edit Comment")
      |> assign(:task, task)
      |> assign(:comment, comment)
    else
      {:error, reason} ->
        case Map.has_key?(reason, "code") do
          true ->
            socket
            |> assign(:resource, "comment")
            |> assign(:title, "Edit Comment")
            |> assign(:task, nil)
            |> assign(:comment, nil)
            |> put_flash(:error, "#{reason["message"]}")
            |> push_redirect(
              to:
                "/boards/#{socket.assigns.board_id}/lists/#{socket.assigns.list_id}/tasks/#{socket.assigns.task_id}/index"
            )

          false ->
            socket
            |> put_flash(:error, reason["error"])
            |> push_redirect(
              to:
                "/boards/#{socket.assigns.board_id}/lists/#{socket.assigns.list_id}/tasks/#{socket.assigns.task_id}/index"
            )
        end
    end
  end

  defp apply_action(socket, :new, %{"resource" => "comment"} = _params) do
    socket
    |> assign(:resource, "comment")
    |> assign(:title, "New Comment")
    |> assign(:comment, %Comment{})
  end

  defp apply_action(socket, :index, _params) do
    socket
  end

  @impl true
  def handle_event(
        "delete_comment",
        %{
          "boardid" => board_id,
          "listid" => list_id,
          "taskid" => task_id,
          "commentid" => comment_id
        },
        socket
      ) do
    token = socket.assigns.token

    case Comments.delete_comment(token, board_id, list_id, task_id, comment_id) do
      {:ok, response} ->
        {:noreply,
         socket
         |> put_flash(:info, "#{response["message"]}")
         |> push_redirect(
           to:
             "/boards/#{socket.assigns.board_id}/lists/#{socket.assigns.list_id}/tasks/#{socket.assigns.task_id}/index"
         )}

      {:error, response} ->
        {:noreply,
         socket
         |> put_flash(:error, "#{response["error"]}")
         |> push_redirect(
           to:
             "/boards/#{socket.assigns.board_id}/lists/#{socket.assigns.list_id}/tasks/#{socket.assigns.task_id}/index"
         )}
    end
  end
end
