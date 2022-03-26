defmodule Api.Boards.Board do
  use Ecto.Schema
  import Ecto.Changeset

  schema "boards" do
    field :title, :string, null: false
    field :user_id, :integer, null: false

    timestamps()
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:title, :user_id])
    |> validate_required([:title])
  end
end
