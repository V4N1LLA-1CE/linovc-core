defmodule LinovcCore.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LinovcCoreWeb.Telemetry,
      LinovcCore.Repo,
      {DNSCluster, query: Application.get_env(:linovc_core, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LinovcCore.PubSub},
      # Start a worker by calling: LinovcCore.Worker.start_link(arg)
      # {LinovcCore.Worker, arg},
      # Start to serve requests, typically the last entry
      LinovcCoreWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LinovcCore.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LinovcCoreWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
