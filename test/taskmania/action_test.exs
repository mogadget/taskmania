defmodule Taskmania.ActionTest do
  use Taskmania.DataCase

  alias Taskmania.Action

  describe "todos" do
    alias Taskmania.Action.Todo

    @valid_attrs %{deleted_at: "2010-04-17T14:00:00Z", details: "some details", name: "some name", todo_date: "2010-04-17T14:00:00Z", type: "some type"}
    @update_attrs %{deleted_at: "2011-05-18T15:01:01Z", details: "some updated details", name: "some updated name", todo_date: "2011-05-18T15:01:01Z", type: "some updated type"}
    @invalid_attrs %{deleted_at: nil, details: nil, name: nil, todo_date: nil, type: nil}

    def todo_fixture(attrs \\ %{}) do
      {:ok, todo} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Action.create_todo()

      todo
    end

    test "list_todos/0 returns all todos" do
      todo = todo_fixture()
      assert Action.list_todos() == [todo]
    end

    test "get_todo!/1 returns the todo with given id" do
      todo = todo_fixture()
      assert Action.get_todo!(todo.id) == todo
    end

    test "create_todo/1 with valid data creates a todo" do
      assert {:ok, %Todo{} = todo} = Action.create_todo(@valid_attrs)
      assert todo.deleted_at == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert todo.details == "some details"
      assert todo.name == "some name"
      assert todo.todo_date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert todo.type == "some type"
    end

    test "create_todo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Action.create_todo(@invalid_attrs)
    end

    test "update_todo/2 with valid data updates the todo" do
      todo = todo_fixture()
      assert {:ok, %Todo{} = todo} = Action.update_todo(todo, @update_attrs)
      assert todo.deleted_at == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert todo.details == "some updated details"
      assert todo.name == "some updated name"
      assert todo.todo_date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert todo.type == "some updated type"
    end

    test "update_todo/2 with invalid data returns error changeset" do
      todo = todo_fixture()
      assert {:error, %Ecto.Changeset{}} = Action.update_todo(todo, @invalid_attrs)
      assert todo == Action.get_todo!(todo.id)
    end

    test "delete_todo/1 deletes the todo" do
      todo = todo_fixture()
      assert {:ok, %Todo{}} = Action.delete_todo(todo)
      assert_raise Ecto.NoResultsError, fn -> Action.get_todo!(todo.id) end
    end

    test "change_todo/1 returns a todo changeset" do
      todo = todo_fixture()
      assert %Ecto.Changeset{} = Action.change_todo(todo)
    end
  end
end
