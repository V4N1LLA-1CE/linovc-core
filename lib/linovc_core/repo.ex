defmodule LinovcCore.Repo do
  use Ecto.Repo,
    otp_app: :linovc_core,
    adapter: Ecto.Adapters.Postgres
end
