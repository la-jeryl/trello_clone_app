defmodule ClientWeb.RegistrationController do
  use ClientWeb, :controller

  # alias Client.Accounts
  alias Client.Users.User
  alias Client.Registrations
  alias ClientWeb.SessionController
  alias Ecto.Changeset

  def new(conn, _params) do
    changeset = User.change_user_registration(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    %{
      "email" => email,
      "password" => password,
      "password_confirmation" => password_confirmation,
      "role" => role
    } = user_params

    # case Registrations.register(email, password, password_confirmation, role) do
    #   {:ok, _session} ->
    #     {:noreply,
    #      socket |> put_flash(:info, "Account created successfully") |> push_redirect(to: "/board")}

    #   {:error, reason} ->
    #     {:noreply, socket |> put_flash(:error, reason)}
    # end

    case Registrations.register(email, password, password_confirmation, role) do
      {:ok, _session} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> SessionController.create(%{"user" => %{"email" => email, "password" => password}})

      {:error, error} ->
        changeset =
          case error.type do
            "email" ->
              custom_changeset(email, password, :email, error.reason, :insert)

            "password" ->
              custom_changeset(email, password, :password, error.reason, :insert)

            "password_confirmation" ->
              custom_changeset(email, password, :password_confirmation, error.reason, :insert)

            _ ->
              custom_changeset(email, password, :email, error.reason, :insert)
          end

        render(conn, "registration.html", changeset: changeset)
    end
  end

  defp custom_changeset(email, password, field_atom, message, action_atom) do
    initial_changeset =
      Changeset.cast(%User{email: email, password: password}, %{}, [
        :email,
        :password
      ])

    error_changeset = Changeset.add_error(initial_changeset, field_atom, message)
    {:error, final_changeset} = Changeset.apply_action(error_changeset, action_atom)

    final_changeset
  end
end
