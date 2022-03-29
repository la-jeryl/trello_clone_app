defmodule Api.Comments.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  alias Api.Tasks.Task
  alias Api.Users.User

  schema "comments" do
    field :description, :string, null: false
    belongs_to(:user, User)
    belongs_to(:task, Task)

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:description, :user_id])
    |> validate_required([:description])
    |> assoc_constraint(:user)
    |> assoc_constraint(:task)
  end
end
