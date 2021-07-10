defmodule Taskmania.Repo.Migrations.AddStatusToTask do
  use Ecto.Migration

  def change do
    alter table("tasks") do
      add :status, :string
      add :comment, :text
    end
  end
end
