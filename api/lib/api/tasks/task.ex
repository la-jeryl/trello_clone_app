defmodule Api.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  alias Api.Lists.List
  alias Api.Users.User
  alias Api.Comments.Comment

  schema "tasks" do
    field :description, :string, null: true
    field :order, :integer, null: false

    field :status, Ecto.Enum,
      values: [:not_started, :in_progress, :completed],
      default: :not_started

    field :title, :string, null: false
    belongs_to(:user, User)
    belongs_to(:list, List)
    has_many(:comments, Comment, on_replace: :delete)

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :order, :status, :user_id, :list_id])
    |> cast_assoc(:comments)
    |> validate_required([:title, :order, :status])
    |> assoc_constraint(:list)
    |> assoc_constraint(:user)
  end
end
