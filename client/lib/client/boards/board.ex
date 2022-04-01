defmodule Client.Boards.Board do
  use Ecto.Schema
  import Ecto.Changeset

  schema "boards" do
    field :title, :string
    field :user_id, :integer
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:title, :user_id])
    |> validate_required([:title, :user_id])
  end
end
