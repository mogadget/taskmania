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
    socket = assign(socket, tasks: tasks)

    {:noreply, socket}
  end

  def handle_event("failed", %{"id" => id}, socket) do
    task = Action.get_task!(id)
    {:ok, task} = Action.update_task(task, %{status: "Failed"})

    tasks = Action.get_todo_tasks(task.todo_id)
    socket = assign(socket, tasks: tasks)

    {:noreply, socket}
  end

  def handle_event("task_add_complete", %{"id" => id}, socket) do
    todo = Action.get_todo!(id)
    {:ok, todo} = Action.update_todo(todo, %{status: "Ready"})

    socket = assign(socket, todo: todo)

    {:noreply, socket}
  end

  def render(assigns) do
    ~L"""

    <h4 class="mb-3"><%= @todo.name %></h4>
    <p><%= @todo.details %></p>
    <div id="create">
      <%= if @todo.status == "New" do %>
        <div class="container">
          <div class="row alert alert-primary">
            <div class="col-10">
              <p>This page list all the tasks that are needed to perform the Todo process <strong><%= @todo.name %></strong>.  A task might be dependent to other tasks to complete or can only be performed by a designated person or role.</p>
              <p><strong>Note :</strong> These tasks will remain in draft mode or "New" status until the "Done Adding Task" button is clicked to set to Ready status.</p>
            </div>
            <div class="col-2">
              <%= live_patch "+ Add Task", to: Routes.todos_show_path(@socket, :modal_new, @todo.id), class: "btn btn-success mb-2 w-100" %>

              <%= if length(@tasks) > 0 do %>
                <div class="btn btn-info w-100 " phx-click="task_add_complete" phx-value-id="<%= @todo.id %>" phx-disable-with="updating...">
                  Done Adding Tasks
                </div>
              <% end %>

              <%= if @live_action == :modal_new do %>
                <%= live_component(
                      TaskmaniaWeb.ModalComponent,
                      id: :modal,
                      component: TaskmaniaWeb.ModalComponent,
                      return_to: Routes.todos_show_path(@socket, :show, @todo.id),
                      changeset: @changeset,
                      tasks: @tasks,
                      todo: @todo
                    ) %>
              <% end %>
            </div>
          </div>
        </div>
      <% end %>

      <%= if length(@tasks) > 0 do %>
        <table class="table table-striped">
          <thead>
              <tr>
                  <th scope="col" width="1%">#</th>
                  <th scope="col">Name</th>
                  <th scope="col">Details</th>
                  <th scope="col">Status</th>
                  <th scope="col" colspan="2">Action</th>
              </tr>
          </thead>
          <tbody>
            <div id="todos" phx-update="prepend">
              <%= for {task, _idx} <- Enum.with_index(@tasks) do %>
                  <tr class="task <%= classy(task.status) %>" id="<%= task.id %>">
                      <th scope="row"><%= task.sequence %></th>
                      <td><%= task.name %></td>
                      <td><%= task.details%></td>
                      <td><%= task.status%></td>
                      <td width="1%">
                        <%= if @todo.status == "Ready" && task.status != "Completed" && task.status != "Failed" do %>
                          <div class="btn btn-danger btn-sm" phx-click="failed" phx-value-id="<%= task.id %>" phx-disable-with="updating...">
                            Failed
                          </div>
                        <% end %>
                      </td>
                      <td width="1%">
                        <%= if @todo.status == "Ready" && task.status != "Completed" && task.status != "Failed" do %>
                          <div class="btn btn-success btn-sm" phx-click="complete" phx-value-id="<%= task.id %>" phx-disable-with="updating...">
                            Done
                          </div>
                        <% end %>
                      </td>
                  </tr>
              <% end %>
            </div>
          </tbody>
        </table>
      <% else %>
        <div class="alert alert-warning">No tasks are created for the process Todo <%= @todo.name %>!</div>
      <% end %>
      <p><%= link "Return to list of Todos", class: "btn btn-warning", to: Routes.todos_path(@socket, :index)%></p>
    </div>

    """
  end

  defp classy(status) do
    case status do
      "Completed" ->
        "table-success"
      "Failed" ->
        "table-danger"
      _ ->
        ""
    end
  end

  defp next_task_order(todo_id) do
    Action.next_task_order(todo_id)
  end
end
