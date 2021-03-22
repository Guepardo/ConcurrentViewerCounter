defmodule Sup.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = [
      sup: [
        strategy: Cluster.Strategy.Gossip
      ]
    ]

    children = [
      {Cluster.Supervisor, [topologies, [name: :name_this]]},
      # Starts a worker by calling: Sup.Worker.start_link(arg)
      # {Sup.Worker, arg}
      {Cachex, name: :my_cache_name},
      {Phoenix.PubSub, name: :pubsub},
      {CurrentViewersDynamicSupervisor, {}}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Sup.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
