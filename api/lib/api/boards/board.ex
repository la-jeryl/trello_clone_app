defmodule Api.Boards.Board do
  use Ecto.Schema
  import Ecto.Changeset

  alias Api.Users.User

  schema "boards" do
    field :title, :string, null: false
    belongs_to(:user, User)

    timestamps()
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:title, :user_id])
    |> validate_required([:title])
    |> assoc_constraint(:user)
  end
end
