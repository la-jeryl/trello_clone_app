defmodule ClientWeb.BoardLive.Index do
  use ClientWeb, :live_view

  alias Client.Tasks
  alias Client.Tasks.Task
  alias Client.Lists
  alias Client.Lists.List
  alias Client.Boards
  import ClientWeb.LiveHelpers

  @impl true
  def mount(params, session, socket) do
    board_id =
      case params["id"] == nil do
        true -> session["board_id"]
        false -> params["id"] |> String.to_integer()
      end

    with {:ok, board} <- Boards.get_board(session["user_token"], board_id),
         {:ok, lists} <- Lists.list_lists(session["user_token"], board_id) do
      socket =
        socket
        |> assign(:token, session["user_token"])
        |> assign(:user_id, session["current_user"]["id"])
        |> assign(:boards, session["boards"])
        |> assign(:board, board)
        |> assign(:lists, lists)

      {:ok, socket}
    else
      {:error, reason} ->
        case Map.has_key?(reason, "code") do
          true ->
            {:ok,
             socket
             |> assign(:boards, nil)
             |> assign(:board, nil)
             |> assign(:lists, nil)
             |> put_flash(:error, "#{reason["message"]}. Login again.")
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

  defp apply_action(socket, :edit, %{"resource" => "list"} = params) do
    %{"board_id" => board_id, "list_id" => list_id} = params

    with {:ok, list} <- Lists.get_list(socket.assigns.token, board_id, list_id) do
      socket
      |> assign(:resource, "list")
      |> assign(:title, "Edit List")
      |> assign(:list, list)
      |> assign(:task, %Task{})
    end
  end

  defp apply_action(socket, :edit, %{"resource" => "task"} = params) do
    %{"board_id" => board_id, "list_id" => list_id, "task_id" => task_id} = params

    with {:ok, list} <- Lists.get_list(socket.assigns.token, board_id, list_id),
         {:ok, task} <- Tasks.get_task(socket.assigns.token, board_id, list_id, task_id) do
      socket
      |> assign(:resource, "task")
      |> assign(:title, "Edit Task")
      |> assign(:list, list)
      |> assign(:task, task)
    end
  end

  defp apply_action(socket, :new, %{"resource" => "list"} = _params) do
    socket
    |> assign(:resource, "list")
    |> assign(:title, "New List")
    |> assign(:list, %List{})
    |> assign(:task, %Task{})
  end

  defp apply_action(socket, :new, %{"resource" => "task"} = params) do
    with {:ok, list} <-
           Lists.get_list(
             socket.assigns.token,
             params["board_id"],
             params["list_id"]
           ) do
      socket
      |> assign(:resource, "task")
      |> assign(:title, "New Task")
      |> assign(:list, list)
      |> assign(:task, %Task{})
    end
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:list, nil)
  end

  @impl true
  def handle_event("delete_list", %{"boardid" => board_id, "listid" => list_id}, socket) do
    token = socket.assigns.token

    case Lists.delete_list(token, board_id, list_id) do
      {:ok, response} ->
        {:noreply,
         socket
         |> put_flash(:info, "#{response["message"]}")
         |> push_redirect(to: "/boards?id=#{board_id}")}

      {:error, response} ->
        {:noreply,
         socket
         |> put_flash(:error, "#{response["error"]}")
         |> push_redirect(to: "/boards?id=#{board_id}")}
    end
  end

  @impl true
  def handle_event(
        "delete_task",
        %{"boardid" => board_id, "listid" => list_id, "taskid" => task_id},
        socket
      ) do
    token = socket.assigns.token

    case Tasks.delete_task(token, board_id, list_id, task_id) do
      {:ok, response} ->
        {:noreply,
         socket
         |> put_flash(:info, "#{response["message"]}")
         |> push_redirect(to: "/boards?id=#{board_id}")}

      {:error, response} ->
        {:noreply,
         socket
         |> put_flash(:error, "#{response["error"]}")
         |> push_redirect(to: "/boards?id=#{board_id}")}
    end
  end
end
