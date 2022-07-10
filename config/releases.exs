import Config

secret_key_base = System.fetch_env!("SECRET_KEY_BASE")
port = System.fetch_env!("PORT")
hostname = System.fetch_env!("HOSTNAME")
github_access_token = System.fetch_env!("GITHUB_ACCESS_TOKEN")
github_batch_size = System.get_env("GITHUB_BATCH_SIZE") || "10"

config :guess_that_lang, GuessThatLangWeb.Endpoint,
  http: [:inet6, port: String.to_integer(port)],
  secret_key_base: secret_key_base

config :guess_that_lang,
  port: port,
  hostname: hostname

config :guess_that_lang, GuessThatLang.CodeSearcher.Github,
  access_token: github_access_token,
  batch_size: String.to_integer(github_batch_size)
