defmodule TaskmaniaWeb.TodosLive.New do
  use TaskmaniaWeb, :live_view

  alias Taskmania.Action
  alias Taskmania.Action.Todo

  def mount(_params, _session, socket) do
    changeset = Action.change_todo(%Todo{})

    socket =
      assign(socket,
        changeset: changeset
      )

    {:ok, socket}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"todo" => params}, socket) do
    case Action.create_todo(params) do
      {:ok, todo} ->
        changeset = Action.change_todo(%Todo{})
        socket = assign(socket, changeset: changeset)

        {:noreply,
        socket
          |> put_flash(:info, "Todo created successfully.")
          |> redirect(to: Routes.todos_show_path(socket, :show, todo.id))}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, changeset: changeset)
        {:noreply, socket}
    end
  end

  def render(assigns) do
    #tasks = assigns.tasks
    changeset = assigns.changeset
    ~L"""
      <h4 class="mb-3">New Todo</h4>
      <div id="create">
        <%= f = form_for @changeset, "#", phx_submit: :save %>

          <div class="mb-3">
              <%= text_input f, :name, required: true, class: "form-control", placeholder: "Name", autocomplete: "off" %>
              <%= error_tag f, :name %>
          </div>

          <div class="mb-3">
              <%= select f, :type, ["Select Type": nil, "Date Specific": "Date", "Process": "Process"], class: "form-select" %>
              <%= error_tag f, :type %>
          </div>

          <div class="mb-3">
              <%= textarea f, :details, class: "form-control", placeholder: "Detail description" %>
          </div>

          <div class="mb-3">
              <%= submit "Create", class: "btn btn-success", phx_disable_with: "creating..." %>
          </div>
        </form>
      </div>
    """
  end


end
