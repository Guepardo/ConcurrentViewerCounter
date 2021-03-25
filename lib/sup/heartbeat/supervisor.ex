defmodule Sup.Heartbeat.Supervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children = [
      {Sup.Heartbeat.Ingest, :ok},
      {Sup.Heartbeat.Consumer, :ok}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
