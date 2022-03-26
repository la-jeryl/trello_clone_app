defmodule Api.Boards.Board do
  use Ecto.Schema
  import Ecto.Changeset

  alias Api.Users.User
  alias Api.Lists.List

  schema "boards" do
    field :title, :string, null: false
    belongs_to(:user, User)
    has_many(:lists, List, on_replace: :delete)

    timestamps()
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:title, :user_id])
    |> cast_assoc(:lists)
    |> validate_required([:title])
    |> assoc_constraint(:user)
  end
end
