defmodule Client.Lists.List do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lists" do
    field :order, :integer, null: false
    field :title, :string, null: false
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:title, :order])
    |> validate_required([:title, :order])
  end
end
