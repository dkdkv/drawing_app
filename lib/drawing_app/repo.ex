defmodule DrawingApp.Repo do
  use Ecto.Repo,
    otp_app: :drawing_app,
    adapter: Ecto.Adapters.Postgres
end
