defmodule TaskmaniaWeb.TodosLive.Show do
  use TaskmaniaWeb, :live_view

  alias Taskmania.Action
  alias Taskmania.Action.Task

  def mount(%{"id" => id}, _session, socket) do
    todo  = Action.get_todo!(id)
    tasks = Action.get_todo_tasks(id)

    socket =
      assign(socket,
        todo: todo,
        tasks: tasks
      )
    changeset = Action.change_task(%Task{})

    socket = assign(socket, changeset: changeset)
    {:ok, socket}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"task" => params}, socket) do
    todo_id = socket.assigns.todo.id

    params = params
      |> Map.put("todo_id", todo_id)
      |> Map.put("sequence", next_task_order(todo_id))

    case Action.create_task(params) do
      {:ok, task} ->
        socket = update(socket, :tasks, fn tasks -> [task| tasks] end)

        changeset = Action.change_task(%Task{})

        socket = assign(socket, changeset: changeset)

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, changeset: changeset)
        {:noreply, socket}
    end
  end

  def handle_event("complete", %{"id" => id}, socket) do
    task = Action.get_task!(id)
    {:ok, task} = Action.update_task(task, %{status: "Completed"})

    tasks = Action.get_todo_tasks(task.todo_id)
    {:ok, todo} = Action.update_todo_status(task.todo_id, "Completed")

    socket = assign(socket, tasks: tasks, todo: todo)

    {:noreply, socket}
  end

  def handle_event("failed", %{"id" => id}, socket) do
    task = Action.get_task!(id)
    {:ok, task} = Action.update_task(task, %{status: "Failed"})

    tasks = Action.get_todo_tasks(task.todo_id)
    {:ok, todo} = Action.update_todo_status(task.todo_id, "Failed")

    socket = assign(socket, tasks: tasks, todo: todo)

    {:noreply, socket}
  end

  def handle_event("task_add_complete", %{"id" => id}, socket) do
    todo = Action.get_todo!(id)
    {:ok, todo} = Action.update_todo(todo, %{status: "Ready"})

    socket = assign(socket, todo: todo)

    {:noreply, socket}
  end

  def render(assigns) do
    TaskmaniaWeb.TodoLiveView.render("todo_live_show.html", assigns)
  end

  defp next_task_order(todo_id) do
    Action.next_task_order(todo_id)
  end
end
