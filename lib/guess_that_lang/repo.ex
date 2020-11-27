defmodule GuessThatLang.Repo do
  use Ecto.Repo,
    otp_app: :guess_that_lang,
    adapter: Ecto.Adapters.Postgres
end
