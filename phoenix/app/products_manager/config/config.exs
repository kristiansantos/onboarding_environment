# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :products_manager,
  ecto_repos: [ProductsManager.Repo]

# Configures the endpoint
config :products_manager, ProductsManagerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "6xWk0JR6ljdROor2vode+3cfxamzkAjK+kkq4p27eoM5nxhrBZRRi27bqvj9TesK",
  render_errors: [view: ProductsManagerWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: ProductsManager.PubSub,
  live_view: [signing_salt: "zGsYlhwB"]


# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Redis Host
config :redix, host: "redis://localhost:6379"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
