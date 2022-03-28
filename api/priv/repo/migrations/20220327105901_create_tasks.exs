defmodule Api.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :string, null: false
      add :description, :string, null: true
      add :order, :integer, null: false
      add :status, :string
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :list_id, references(:lists, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:tasks, [:user_id])
    create index(:tasks, [:list_id])
  end
end
