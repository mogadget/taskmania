defmodule Taskmania.Repo do
  use Ecto.Repo,
    otp_app: :taskmania,
    adapter: Ecto.Adapters.Postgres
end
