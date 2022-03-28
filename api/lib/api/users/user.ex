defmodule Api.Users.User do
  use Ecto.Schema
  use Pow.Ecto.Schema

  alias Api.Boards.Board
  alias Api.Lists.List
  alias Api.Tasks.Task

  schema "users" do
    has_many(:boards, Board, on_replace: :delete)
    has_many(:lists, List, on_replace: :delete)
    has_many(:tasks, Task, on_replace: :delete)
    pow_user_fields()

    timestamps()
  end
end
