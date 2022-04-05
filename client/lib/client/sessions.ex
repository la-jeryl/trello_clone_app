defmodule Client.Sessions do
  use Tesla

  # plug(Tesla.Middleware.BaseUrl, "http://localhost:4000/api")
  plug(Tesla.Middleware.BaseUrl, "http://172.20.0.4:4000/api")
  plug(Tesla.Middleware.JSON)

  def login(email, password) do
    with {:ok, response} <-
           post("/session", %{
             user: %{
               email: email,
               password: password
             }
           }) do
      case Map.has_key?(response.body, "data") do
        true ->
          {:ok, response.body["data"]}

        false ->
          {:error, response.body["error"]}
      end
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def renew(renewal_token) do
    client = Tesla.client([{Tesla.Middleware.Headers, [{"authorization", renewal_token}]}])

    with {:ok, response} <- post(client, "/session/renew", %{}) do
      case Map.has_key?(response.body, "data") do
        true ->
          {:ok, response.body["data"]}

        false ->
          {:error, response.body["error"]}
      end
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def logout(token) do
    client = Tesla.client([{Tesla.Middleware.Headers, [{"authorization", token}]}])

    with {:ok, response} <- delete(client, "/session") do
      case Map.has_key?(response.body, "data") do
        true ->
          {:ok, %{"message" => "User logged out."}}

        false ->
          {:error, response.body["error"]}
      end
    else
      {:error, reason} -> {:error, reason}
    end
  end
end
