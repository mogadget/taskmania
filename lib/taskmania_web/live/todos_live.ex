defmodule TaskmaniaWeb.TodosLive do
  use TaskmaniaWeb, :live_view

  alias Taskmania.Action
  alias Taskmania.Action.Todo

  def mount(_params, _session, socket) do
    todos = Action.list_todos()
    changeset = Action.change_todo(%Todo{})

    socket =
      assign(socket,
        todos: todos,
        changeset: changeset
      )

    {:ok, socket, temporary_assigns: [todos: []]}
  end

  def handle_event("save", %{"todo" => params}, socket) do
    case Action.create_todo(params) do
      {:ok, todo} ->
        socket =
          update(
            socket,
            :todos,
            fn todos -> [todo| todos] end
          )

        changeset = Action.change_todo(%Todo{})

        socket = assign(socket, changeset: changeset)

        :timer.sleep(500)

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, changeset: changeset)
        {:noreply, socket}
    end
  end
end
