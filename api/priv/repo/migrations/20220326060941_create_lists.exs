defmodule Api.Repo.Migrations.CreateLists do
  use Ecto.Migration

  def change do
    create table(:lists) do
      add :title, :string, null: false
      add :order, :integer, null: false
      add :board_id, references(:boards, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:lists, [:board_id])
    create index(:lists, [:user_id])
  end
end
