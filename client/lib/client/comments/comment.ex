defmodule Client.Comments.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :description, :string, null: false
    field :user_id, :integer
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:description, :user_id])
    |> validate_required([:description, :user_id])
  end
end
