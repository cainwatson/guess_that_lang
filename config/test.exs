use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :guess_that_lang, GuessThatLangWeb.Endpoint,
  http: [port: 4002],
  server: false

config :guess_that_lang, GuessThatLang.CodeSearcher,
  searcher: GuessThatLang.CodeSearcher.MockSearcher

# Print only warnings and errors during test
config :logger, level: :warn
