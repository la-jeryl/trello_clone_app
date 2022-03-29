defmodule Client.Comments.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :description, :string, null: false
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:description])
    |> validate_required([:description])
  end
end
