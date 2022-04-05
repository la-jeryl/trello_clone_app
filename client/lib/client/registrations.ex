defmodule Client.Registrations do
  use Tesla

  # plug Tesla.Middleware.BaseUrl, "http://localhost:4000/api"
  plug(Tesla.Middleware.BaseUrl, "http://172.20.0.4:4000/api")
  plug(Tesla.Middleware.JSON)

  def register(email, password, password_confirmation, role) do
    with true <- password == password_confirmation,
         {:ok, response} <-
           post("/registration", %{
             user: %{
               email: email,
               password: password,
               password_confirmation: password_confirmation,
               role: role
             }
           }) do
      case Map.has_key?(response.body, "data") do
        true ->
          {:ok, response.body["data"]}

        false ->
          error_check(response.body["error"]["errors"])
      end
    else
      false ->
        {:error, %{reason: "Passwords do not match.", type: "password_confirmation"}}

      {:error, _reason} ->
        {:error, %{reason: "Cannot register the account.", type: "email"}}
    end
  end

  defp error_check(%{"email" => [value]}),
    do: {:error, %{reason: "Email #{value}.", type: "email"}}

  defp error_check(%{"password" => [value]}),
    do: {:error, %{reason: "Password #{value}.", type: "password"}}
end
