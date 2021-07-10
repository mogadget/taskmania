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

  def handle_event("save", %{"task" => params}, socket) do
    #todo = assign(socket)
    IO.inspect(["---->", params, socket])

    params = Map.put(params, "todo_id", socket.assigns.todo.id)

    case Action.create_task(params) do
      {:ok, task} ->
        socket =
          update(
            socket,
            :tasks,
            fn tasks -> [task| tasks] end
          )

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
    todo  = assigns.todo
    #tasks = assigns.tasks
    changeset = assigns.changeset
    ~L"""

    <h4 class="mb-3"><%= todo.name %> Tasks</h4>
    <div id="create">
      <%= if todo.status == "New" do %>
        <%= f = form_for changeset, "#", phx_submit: :save %>

          <div class="mb-3">
            <%= text_input f, :name, required: true, class: "form-control", placeholder: "Name", autocomplete: "off" %>
            <%= error_tag f, :name %>
          </div>

          <div class="mb-3">
            <%= textarea f, :details, class: "form-control", placeholder: "Detail description" %>
          </div>

          <div class="mb-3">
            <%= submit "Add Task", class: "btn btn-success", phx_disable_with: "appending..." %>
            <%= if length(@tasks) > 0 do %>
            <div class="btn btn-info" phx-click="task_add_complete" phx-value-id="<%= todo.id %>" phx-disable-with="updating...">
              Done Adding Tasks
            </div>
            <% end %>
          </div>
        </form>
      <% end %>
      <%= if length(@tasks) > 0 do %>
        <table class="table table-striped">
          <thead>
              <tr>
                  <th scope="col">#</th>
                  <th scope="col">Name</th>
                  <th scope="col">Details</th>
                  <th scope="col">Status</th>
                  <th scope="col" width="1%"></th>
                  <th scope="col" width="1%"></th>
              </tr>
          </thead>
          <tbody>
            <div id="todos" phx-update="prepend">
              <%= for {task, idx} <- Enum.with_index(@tasks) do %>
                  <tr class="task <%= classy(task.status) %>" id="<%= task.id %>">
                      <th scope="row"><%= idx + 1 %></th>
                      <td><%= task.name %></td>
                      <td><%= task.details%></td>
                      <td><%= task.status%></td>
                      <td>
                        <%= if todo.status == "Ready" && task.status != "Completed" && task.status != "Failed" do %>
                          <div class="btn btn-danger btn-sm" phx-click="failed" phx-value-id="<%= task.id %>" phx-disable-with="updating...">
                            Failed
                          </div>
                        <% end %>
                      </td>
                      <td>
                        <%= if todo.status == "Ready" && task.status != "Completed" && task.status != "Failed" do %>
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
        <div class="alert alert-warning">No tasks are created for the Todo!</div>
      <% end %>
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
    #if task.status == "Completed", do: "table-success"
  end
end
