defmodule Client.Lists.List do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lists" do
    field :order, :integer, null: false
    field :title, :string, null: false
    field :user_id, :integer
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:title, :order, :user_id])
    |> validate_required([:title, :order, :user_id])
  end
end
