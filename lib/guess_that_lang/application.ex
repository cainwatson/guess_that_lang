defmodule GuessThatLang.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  require Logger
  use Application

  def start(_type, _args) do
    Logger.info(
      "Starting application on version: #{Application.get_env(:guess_that_lang, :version)}"
    )

    children = [
      # Start the Ecto repository
      # GuessThatLang.Repo,
      # Start the Telemetry supervisor
      GuessThatLangWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: GuessThatLang.PubSub},
      # Start the Endpoint (http/https)
      GuessThatLangWeb.Endpoint
      # Start a worker by calling: GuessThatLang.Worker.start_link(arg)
      # {GuessThatLang.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GuessThatLang.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    GuessThatLangWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
