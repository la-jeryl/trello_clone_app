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

  def change_user_registration(%__MODULE__{} = user, attrs \\ %{}) do
    __MODULE__.registration_changeset(user, attrs, hash_password: false)
  end

  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_email()
    |> validate_password(opts)
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, Client.Repo)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset, _opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 5, max: 72)
  end
end
