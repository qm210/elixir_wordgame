defmodule ElixirWordgame.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ElixirWordgameWeb.Telemetry,
      ElixirWordgame.Repo,
      {DNSCluster, query: Application.get_env(:elixir_wordgame, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ElixirWordgame.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ElixirWordgame.Finch},
      # Start a worker by calling: ElixirWordgame.Worker.start_link(arg)
      # {ElixirWordgame.Worker, arg},
      # Start to serve requests, typically the last entry
      ElixirWordgameWeb.Endpoint,
      ElixirWordgame.Game
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirWordgame.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ElixirWordgameWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
