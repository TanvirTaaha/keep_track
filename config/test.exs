import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :keep_track, KeepTrack.Repo,
  database: Path.expand("../keep_track_test.db", __DIR__),
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :keep_track, KeepTrackWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "VA35r0yywY3FKjxjsoq7F99tSnN4SNU8WrHiBRDKmdHY8qLHzuI+5m4ujsLMjmoT",
  server: false

# In test we don't send emails
config :keep_track, KeepTrack.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
