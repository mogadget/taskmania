defmodule TaskmaniaWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  alias Taskmania.Accounts

  def live_modal(_socket, component, opts) do
    live_component(
      TaskmaniaWeb.ModalComponent,
      id: :modal,
      component: component,
      return_to: Keyword.fetch!(opts, :return_to),
      changeset: Keyword.fetch!(opts, :changeset),
      tasks: Keyword.fetch!(opts, :tasks),
      opts: opts
    )
  end

  def assign_current_user(socket, session) do
    assign_new(
      socket,
      :current_user,
      fn ->
        Accounts.get_user_by_session_token(session["user_token"])
      end
    )
  end
end
