# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :linovc_core,
  ecto_repos: [LinovcCore.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :linovc_core, LinovcCoreWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: LinovcCoreWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: LinovcCore.PubSub,
  live_view: [signing_salt: "8tyTVCBw"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :linovc_core, LinovcCore.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Guardian configs for JWT auth
config :linovc_core, LinovcCore.Accounts.Guardian,
  issuer: "venli-backend-core",
  secret_key: "-jKMZybcHHWaAKXyV3cp1nxNiFo673AKChqJAV4nNRz1Ej9etBbyaV-a_Z1wm9Z_"

config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, []}
  ]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET")

config :cors_plug,
  origin: ["http://localhost:3000"],
  max_age: 86400,
  methods: ["GET", "POST", "PATCH", "PUT", "DELETE", "OPTIONS"],
  headers: [
    "Authorization",
    "Content-Type",
    "Accept",
    "Origin",
    "User-Agent",
    "X-Requested-With",
    "X-CSRF-Token"
  ],
  send_preflight_response?: true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
