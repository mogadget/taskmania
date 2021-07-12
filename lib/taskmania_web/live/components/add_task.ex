defmodule TaskmaniaWeb.ModalComponent do
  use TaskmaniaWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="phx-modal" phx-window-keydown="close" phx-key="escape" phx-capture-click="close" phx-target="<%= @myself %>">
      <div class="phx-modal-content">
        <%= live_patch raw("&times;"),  to: @return_to,  class: "phx-modal-close" %>
        <h4>Add new Task</h4>
        <hr/>
        <%= f = form_for @changeset, "#", phx_submit: :save %>

          <div class="mb-3">
            <%= text_input f, :name, class: "form-control", placeholder: "name of task", autocomplete: "off" %>
            <%= error_tag f, :name %>
          </div>

          <div class="mb-3">
            <%= text_input f, :dependencies, class: "form-control", placeholder: "list of dependent tasks", autocomplete: "off" %>
            <%= error_tag f, :dependencies %>
          </div>

          <div class="mb-3">
            <%= textarea f, :details, class: "form-control", placeholder: "task detailed description" %>
            <%= error_tag f, :details %>
          </div>

          <div class="mb-3">
            <%= submit "Save", class: "btn btn-success", phx_disable_with: "appending..." %>
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
