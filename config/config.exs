# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :word_snake,
  ecto_repos: [WordSnake.Repo]

# Configures the endpoint
config :word_snake, WordSnake.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "VUX+V0PQdm2jD+PVrRnJhlPl45cdf+DXTrMGDO3a6HX5abGaxVhKFdyCRpCzKJQs",
  render_errors: [view: WordSnake.ErrorView, accepts: ~w(json)],
  pubsub: [name: WordSnake.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
