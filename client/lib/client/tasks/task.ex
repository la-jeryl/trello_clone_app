defmodule Client.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :description, :string, null: true
    field :order, :integer, null: false

    field :status, Ecto.Enum,
      values: [:not_started, :in_progress, :completed],
      default: :not_started

    field :title, :string, null: false
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :order, :status])
    |> validate_required([:title, :order, :status])
  end
end
