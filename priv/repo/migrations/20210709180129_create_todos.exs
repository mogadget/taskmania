defmodule Taskmania.Repo.Migrations.CreateTodos do
  use Ecto.Migration

  def change do
    create table(:todos) do
      add :name, :string
      add :type, :string
      add :details, :text
      add :status, :string
      add :todo_date, :utc_datetime
      add :deleted_at, :utc_datetime

      timestamps()
    end

  end
end
