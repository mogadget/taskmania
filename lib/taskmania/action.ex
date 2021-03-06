defmodule Taskmania.Action do
  @moduledoc """
  The Action context.
  """

  import Ecto.Query, warn: false
  alias Taskmania.Repo

  alias Taskmania.Action.Todo
  alias Taskmania.Action.Task

  @doc """
  Returns the list of todos.

  ## Examples

      iex> list_todos()
      [%Todo{}, ...]

  """
  def list_todos do
    Repo.all(Todo)
  end

  def list_todos_by_status do
    Repo.all(Todo)
  end

  def list_todos_by_type do
    Repo.all(Todo)
  end

  @doc """
  Gets a single todo.

  Raises `Ecto.NoResultsError` if the Todo does not exist.

  ## Examples

      iex> get_todo!(123)
      %Todo{}

      iex> get_todo!(456)
      ** (Ecto.NoResultsError)

  """
  def get_todo!(id), do: Repo.get!(Todo, id)

  def get_todo_tasks(id) do
    Task
      |> where([task], task.todo_id == ^id)
      |> preload(:todo)
      |> Repo.all()
  end

  @doc """
  Creates a todo.

  ## Examples

      iex> create_todo(%{field: value})
      {:ok, %Todo{}}

      iex> create_todo(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_todo(attrs \\ %{}) do
    attrs = attrs
      |> Map.put("status", "New")

    %Todo{}
    |> Todo.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a todo.

  ## Examples

      iex> update_todo(todo, %{field: new_value})
      {:ok, %Todo{}}

      iex> update_todo(todo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_todo(%Todo{} = todo, attrs) do
    todo
    |> Todo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
    Update todo status to Completed when total Todo tasks is equal to all Completed tasks
  """
  def update_todo_status(todo_id, status) do
    todo = get_todo!(todo_id)

    total_tasks     = total_todo_task(todo_id)
    total_status = total_task_status(todo_id, status)

    if ( total_tasks > 0 && (total_tasks == total_status)) do
      update_todo(todo, %{status: status})
    else
      {:ok, todo}
    end
  end

  @doc """
  Deletes a todo.

  ## Examples

      iex> delete_todo(todo)
      {:ok, %Todo{}}

      iex> delete_todo(todo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_todo(%Todo{} = todo) do
    Repo.delete(todo)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking todo changes.

  ## Examples

      iex> change_todo(todo)
      %Ecto.Changeset{data: %Todo{}}

  """
  def change_todo(%Todo{} = todo, attrs \\ %{}) do
    Todo.changeset(todo, attrs)
  end

  @spec list_tasks :: any
  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%Task{}, ...]

  """
  def list_tasks do
    Repo.all(Task)
  end

  @doc """
  Gets a single task.

  Raises `Ecto.NoResultsError` if the Task does not exist.

  ## Examples

      iex> get_task!(123)
      %Task{}

      iex> get_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_task!(id), do: Repo.get!(Task, id)

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task(attrs \\ %{}) do
    attrs = attrs
      |> Map.put("status", "New")

    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a task.

  ## Examples

      iex> update_task(task, %{field: new_value})
      {:ok, %Task{}}

      iex> update_task(task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_task(%Task{} = task, attrs) do

    status = Map.get(attrs, :status)
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a task.

  ## Examples

      iex> delete_task(task)
      {:ok, %Task{}}

      iex> delete_task(task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.

  ## Examples

      iex> change_task(task)
      %Ecto.Changeset{data: %Task{}}

  """
  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  def list_types do
    ["Process", "Date"]
  end

  def list_todo_statuses do
    ["Incomplete","Completed"]
  end

  def list_task_statuses do
    ["Pending","Done","Failed"]
  end

  def total_task_status(todo_id, status) do
    query = from t in "tasks",
          where: t.todo_id == ^todo_id and t.status == ^status,
          select: count(t.id)

    Repo.one(query)
  end

  def total_todo_task(todo_id) do
    query = from t in "tasks",
          where: t.todo_id == ^todo_id,
          select: count(t.id)

    Repo.one(query)
  end

  def next_task_order(todo_id) do
    total_todo_task(todo_id) + 1
  end

  def list_todos_with_total() do
    ctask =
      from t in Task,
        group_by: t.todo_id,
        select: %{todo_id: t.todo_id, ctasks: count(t.id)}

    ftask =
      from t in Task,
        group_by: t.todo_id,
        where: t.status == "Failed",
        select: %{todo_id: t.todo_id, ctasks: count(t.id)}

    comp =
      from t in Task,
        group_by: t.todo_id,
        where: t.status == "Completed",
        select: %{todo_id: t.todo_id, ctasks: count(t.id)}

    qtodo = from t in Todo,
      left_join: tasks in subquery(ctask), on: tasks.todo_id == t.id,
      left_join: complete in subquery(comp), on: complete.todo_id == t.id,
      left_join: failed in subquery(ftask), on: failed.todo_id == t.id,
      select: %{
        id: t.id,
        name: t.name,
        status: t.status,
        type: t.type,
        details: t.details,
        total_tasks: tasks.ctasks,
        completed_tasks: complete.ctasks,
        failed_tasks: failed.ctasks},
      order_by: t.id

    Repo.all(qtodo)
  end

end
