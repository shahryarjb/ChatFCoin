import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.

if System.get_env("GITHUB_ACTIONS") do
  config :mishka_database, ChatFCoin.Repo,
    url: System.get_env("DATABASE_URL") || "postgres://localhost:5432/chat_f_coin_test",
    pool: Ecto.Adapters.SQL.Sandbox,
    pool_size: 20,
    show_sensitive_data_on_connection_error: true
else
  config :chat_f_coin, ChatFCoin.Repo,
    username: System.get_env("DB_USERNAME") || "postgres",
    password: System.get_env("DB_PASSWORD") || "postgres",
    hostname: System.get_env("DB_HOSTNAME") || "localhost",
    database: "chat_f_coin_test#{System.get_env("MIX_TEST_PARTITION")}",
    pool: Ecto.Adapters.SQL.Sandbox,
    pool_size: 10
end


# We don't run a server during test. If one is required,
# you can enable the server option below.
config :chat_f_coin, ChatFCoinWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "5i0sp5SkfVzfQn9zna8JRz73Tcb2Jvvcixq3CXQDdSLM1ZpX2D/73IdmCZqfzAmS",
  server: false

# In test we don't send emails.
config :chat_f_coin, ChatFCoin.Mailer, adapter: Swoosh.Adapters.Test

config :chat_f_coin, :http_client, ChatFCoin.Helper.HttpSenderTestMock

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
