defmodule Taskmania.Action.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "todos" do
    field :deleted_at, :utc_datetime
    field :details, :string
    field :name, :string
    field :todo_date, :utc_datetime
    field :type, :string
    field :status, :string

    has_many :tasks, Taskmania.Action.Task
    timestamps()
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:name, :details, :type, :todo_date, :deleted_at, :status])
    |> validate_required([:name, :type])
  end
end
