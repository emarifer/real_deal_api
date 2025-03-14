# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :real_deal_api,
  ecto_repos: [RealDealApi.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# Configures the endpoint
config :real_deal_api, RealDealApiWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: RealDealApiWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: RealDealApi.PubSub,
  live_view: [signing_salt: "GucuG4VE"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Setup Guardian config:
# https://hexdocs.pm/guardian/tutorial-start.html#setup-guardian-config
config :real_deal_api, RealDealApiWeb.Auth.Guardian,
  issuer: "real_deal_api",
  secret_key: "eUn5rc3c7LozyE9B7sZPZWh+ZHse4Tv8ti0/9ZZH7Lz2jjpsltSAAmYT38p4+YU2"

# ↑↑↑ run `mix guardian.gen.secret` ↑↑↑,
# the generator provided with Guardian (HS512 algorithm).

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
