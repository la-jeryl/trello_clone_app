defmodule Client.Boards.Board do
  use Ecto.Schema
  import Ecto.Changeset

  alias Client.Users.User
  alias Client.Lists.List

  schema "boards" do
    field :title, :string, null: false
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
