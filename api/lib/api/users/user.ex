defmodule Api.Users.User do
  use Ecto.Schema
  use Pow.Ecto.Schema

  alias Api.Boards.Board
  alias Api.Lists.List
  alias Api.Tasks.Task

  @roles ~w(read write manage)

  schema "users" do
    has_many(:boards, Board, on_replace: :delete)
    has_many(:lists, List, on_replace: :delete)
    has_many(:tasks, Task, on_replace: :delete)
    field :role, :string, null: false, default: "read"

    pow_user_fields()

    timestamps()
  end

  def changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> pow_changeset(attrs)
    |> Ecto.Changeset.cast(attrs, [:role])
    |> Ecto.Changeset.validate_inclusion(:role, @roles)
  end

  def role_changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> Ecto.Changeset.cast(attrs, [:role])
    |> Ecto.Changeset.validate_inclusion(:role, @roles)
  end
end
