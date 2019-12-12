defmodule UrlLogger.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(scheme: :http, plug: UrlLogger.Router, options: [port: 8080]),
      {Redix, {"redis://localhost:6379", [name: :redix]}}
      # Starts a worker by calling: UrlLogger.Worker.start_link(arg)
      # {UrlLogger.Worker, arg}
    ]

    Logger.info("app started")

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UrlLogger.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
