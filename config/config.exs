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

# Guardian.DB Configuration.
# There is an error in the documentation regarding the Phoenix Framework
# configuration of this module, which has not yet been corrected
# despite a pull request dated November 13, 2023.
# Here is the pull request and the correct documentation for the configuration:
# https://github.com/ueberauth/guardian_db/pull/145
# https://github.com/ueberauth/guardian_db/commit/1003ca148525d8589a7b154fcb9f2a257d27eec2
# https://github.com/ueberauth/guardian_db/commit/1d1671934ae4c38c02310c324044d3542ec599ad
config :guardian, Guardian.DB,
  repo: RealDealApi.Repo,
  schema_name: "guardian_tokens"

# sweep_interval: 60

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
