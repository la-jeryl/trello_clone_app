defmodule Api.Users.User do
  use Ecto.Schema
  use Pow.Ecto.Schema

  alias Api.Boards.Board

  schema "users" do
    has_many(:boards, Board, on_replace: :delete)
    pow_user_fields()

    timestamps()
  end
end
