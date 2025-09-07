import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :linovc_core, LinovcCore.Repo,
  username: "root",
  password: "toor",
  hostname: "localhost",
  database: "linovc_core_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :linovc_core, LinovcCoreWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "shjfkCuj+XAczUY0Pn9aB6i2Aj5qhEysDNd+J2gZRl4Q4r/5mrCSkA53hJMG1T2N",
  server: false

# In test we don't send emails
config :linovc_core, LinovcCore.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
