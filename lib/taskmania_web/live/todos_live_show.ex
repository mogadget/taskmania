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

  def handle_event("done", %{"id" => id}, socket) do
    task = Action.get_task!(id)
    {:ok, task} = Action.update_task(task, %{status: "Completed"})

    tasks = Action.get_todo_tasks(task.todo_id)
    socket = assign(socket, tasks: tasks)

    {:noreply, socket}
  end

  def render(assigns) do
    todo  = assigns.todo
    #tasks = assigns.tasks
    changeset = assigns.changeset
    ~L"""

    <h4 class="mb-3"><%= todo.name %> Tasks</h4>
    <div id="create">
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
            <%= submit "Complete", class: "btn btn-info", phx_disable_with: "completing..." %>
        </div>
      </form>

        <table class="table">
        <thead>
            <tr>
                <th scope="col">#</th>
                <th scope="col">Name</th>
                <th scope="col">Details</th>
                <th scope="col"></th>
            </tr>
        </thead>
        <tbody>
        <div id="todos" phx-update="prepend">
            <%= for {task, idx} <- Enum.with_index(@tasks) do %>
                <tr class="task" id="<%= task.id %>">
                    <th scope="row"><%= idx + 1 %></th>
                    <td><%= task.name %></td>
                    <td><%= task.details%></td>
                    <td>
                      <div class="btn btn-success" phx-click="done" phx-value-id="<%= task.id %>" phx-disable-with="updating...">
                        Done
                      </div>
                    </td>
                </tr>
            <% end %>
            </div>
        </tbody>
        </table>
    </div>

    """
  end
end
