defmodule Client.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :password, :string
    field :confirm_password, :string, null: true

    field :role, Ecto.Enum,
      values: [:read, :write, :manage],
      default: :read
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :confirm_password, :role])
    |> validate_required([:email, :password])
  end
end
