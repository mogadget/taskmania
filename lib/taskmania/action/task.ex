defmodule Taskmania.Action.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :details, :string
    field :name, :string
    field :status, :string
    field :comment, :string
    field :sequence, :integer
    field :dependencies, :string
    field :assigned_to, :string
    field :completed_date, :utc_datetime

    belongs_to :todo, Taskmania.Action.Todo
    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:name, :details, :todo_id, :status, :completed_date, :sequence, :dependencies, :assigned_to])
    |> validate_required([:name, :details])
  end
end
