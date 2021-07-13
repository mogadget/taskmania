defmodule TaskmaniaWeb.TodoLiveView do
  use TaskmaniaWeb, :view

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

  defp status_pctg(total, status_count) do
    if total == nil || total == 0 || status_count == nil do
      0
    else
      (status_count / total) * 100
    end
  end

end
