defmodule Api.Lists.List do
  use Ecto.Schema
  import Ecto.Changeset

  alias Api.Users.User
  alias Api.Boards.Board
  alias Api.Tasks.Task

  schema "lists" do
    field :order, :integer, null: false
    field :title, :string, null: false
    belongs_to(:board, Board)
    belongs_to(:user, User)
    has_many(:tasks, Task, on_replace: :delete)

    timestamps()
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:title, :order, :user_id])
    |> cast_assoc(:tasks)
    |> validate_required([:title, :order])
    |> assoc_constraint(:board)
    |> assoc_constraint(:user)
  end
end
