defmodule TaskmaniaWeb.ModalComponent do
  use TaskmaniaWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="phx-modal" phx-window-keydown="close" phx-key="escape" phx-capture-click="close" phx-target="<%= @myself %>">
      <div class="phx-modal-content">
        <%= live_patch raw("&times;"),  to: @return_to,  class: "phx-modal-close" %>
        <%= f = form_for @changeset, "#", phx_submit: :save %>

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
              <div class="btn btn-info" phx-click="task_add_complete" phx-value-id="<%= @todo.id %>" phx-disable-with="updating...">
                Done Adding Tasks
              </div>
            <% end %>
          </div>
        </form>
      </div>
    </div>
    """
  end

  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end

end
