use Mix.Config

config :guess_that_lang, GuessThatLangWeb.Endpoint,
  server: true,
  url: [
    host: Application.get_env(:guess_that_lang, :hostname),
    port: Application.get_env(:guess_that_lang, :port)
  ],
  cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :info
