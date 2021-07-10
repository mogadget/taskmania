defmodule Taskmania.Action.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :details, :string
    field :name, :string
    field :todo_id, :id
    field :status, :string
    field :completed_date, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:name, :details, :todo_id, :status, :completed_date])
    |> validate_required([:name, :details])
  end
end
