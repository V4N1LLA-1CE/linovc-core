defmodule VenliCore.Repo do
  use Ecto.Repo,
    otp_app: :venli_core,
    adapter: Ecto.Adapters.Postgres
end
