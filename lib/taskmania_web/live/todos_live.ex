defmodule TaskmaniaWeb.TodosLive do
  use TaskmaniaWeb, :live_view

  alias Taskmania.Action
  alias Taskmania.Action.Todo

  def mount(_params, _session, socket) do
    todos = Action.list_todos_with_total()
    changeset = Action.change_todo(%Todo{})

    socket =
      assign(socket,
        todos: todos,
        changeset: changeset
      )

    {:ok, socket}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"todo" => params}, socket) do
    #IO.inspect(["handle-save", socket])
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

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, changeset: changeset)
        {:noreply, socket}
    end
  end

  def handle_event("create", %{"key" => key}, socket) do
    case key do
      "c" ->
        {:noreply,
        socket
          |> redirect(to: Routes.live_path(socket, TaskmaniaWeb.TodosLive.New))}

      _ -> {:noreply, socket}
    end
  end

  def handle_params(%{"sort_by" => sort_by}, socket) do
    case sort_by do
      sort_by
      when sort_by in ~w(type status) ->
        {:noreply, assign(socket, todos: Action.list_todos_by_status)}

      _ ->
        {:noreply, socket}
    end
  end

  defp completed_pctg(total, completed) do
    if total == nil || total == 0 || completed == nil do
      0
    else
      (completed / total) * 100
    end
  end

  defp failed_pctg(total, failed) do
    if total == nil || total == 0 || failed == nil do
      0
    else
      (failed / total) * 100
    end
  end
end
