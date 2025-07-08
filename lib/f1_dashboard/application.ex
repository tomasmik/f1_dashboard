defmodule F1Dashboard.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      F1DashboardWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:f1_dashboard, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: F1Dashboard.PubSub},
      F1DashboardWeb.Endpoint,
      F1Dashboard.Cache.Storage,
      F1Dashboard.Cache.Worker
    ]

    opts = [strategy: :one_for_one, name: F1Dashboard.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    F1DashboardWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
