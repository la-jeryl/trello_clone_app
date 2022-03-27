defmodule Api.Lists.List do
  use Ecto.Schema
  import Ecto.Changeset

  alias Api.Users.User
  alias Api.Boards.Board

  schema "lists" do
    field :order, :integer, null: false
    field :title, :string, null: false
    belongs_to(:board, Board)
    belongs_to(:user, User)

    timestamps()
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:title, :order, :user_id])
    |> validate_required([:title, :order])
    |> assoc_constraint(:board)
    |> assoc_constraint(:user)
  end
end
