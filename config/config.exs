# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :guess_that_lang, GuessThatLangWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "xHvAnqwcTh0GqdFcyRlcpYamKEXIJkm0GcPK8d4R39irs58W88EpRbGguSqFK4hu",
  render_errors: [view: GuessThatLangWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: GuessThatLang.PubSub,
  live_view: [signing_salt: "HJdXqO4Z"]

config :guess_that_lang,
  min_snippet_length: 8

config :guess_that_lang, GuessThatLang.CodeSearcher, searcher: GuessThatLang.CodeSearcher.Github

config :guess_that_lang, GuessThatLang.CodeSearcher.Github,
  access_token: System.get_env("GITHUB_ACCESS_TOKEN"),
  batch_size: String.to_integer(System.get_env("GITHUB_BATCH_SIZE") || "10")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
