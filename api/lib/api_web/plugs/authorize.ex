defmodule ApiWeb.Authorize do
  use ApiWeb, :controller
  import Plug.Conn
  import Api.Authorization

  def init(opts), do: opts

  def call(conn, opts) do
    role = conn.assigns.current_user.role
    resource = Keyword.get(opts, :resource)
    action = action_name(conn)

    check(action, role, resource)
    |> maybe_continue(conn)
  end

  defp maybe_continue(true, conn), do: conn

  defp maybe_continue(false, conn) do
    conn
    |> put_status(:bad_request)
    |> render("error.json", error: "You are not authorized to perform this action.")
    |> halt()
  end

  defp check(action, role, resource) when action in [:index, :show] do
    can(role) |> show?(resource)
  end

  defp check(action, role, resource) when action in [:new, :create] do
    can(role) |> create?(resource)
  end

  defp check(action, role, resource) when action in [:edit, :update] do
    can(role) |> update?(resource)
  end

  defp check(:delete, role, resource) do
    can(role) |> delete?(resource)
  end

  defp check(_action, _role, _resource), do: false
end
