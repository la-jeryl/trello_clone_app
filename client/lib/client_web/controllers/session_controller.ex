defmodule ClientWeb.SessionController do
  use ClientWeb, :controller

  alias ClientWeb.Auth

  alias Client.Sessions

  def new(conn, _params) do
    render(conn, "session.html", error_message: nil)
  end

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    case Sessions.login(email, password) do
      {:ok, session_details} ->
        conn
        |> put_flash(:info, "User logged in successfully.")
        |> Auth.log_in_user(session_details)

      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      {:error, error} ->
        conn |> render("session.html", error_message: error["message"])
    end
  end

  def delete(conn, _params) do
    user_token = Plug.Conn.get_session(conn, :user_token)
    Sessions.logout(user_token)

    conn
    |> put_flash(:info, "User logged out successfully.")
    |> Auth.log_out_user()
  end
end
