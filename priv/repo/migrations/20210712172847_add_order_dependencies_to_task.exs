defmodule Taskmania.Repo.Migrations.AddOrderDependenciesToTask do
  use Ecto.Migration

  def change do
    alter table("tasks") do
      add :sequence, :integer
      add :dependencies, :string
      add :assigned_to, :string
      add :updatedby_id, :string
    end
  end
end
