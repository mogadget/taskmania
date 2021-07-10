defmodule Taskmania.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :name, :string
      add :details, :text
      add :completed_date, :utc_datetime
      add :todo_id, references(:todos, on_delete: :nothing)

      timestamps()
    end

    create index(:tasks, [:todo_id])
  end
end
