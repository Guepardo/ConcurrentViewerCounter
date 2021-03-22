defmodule Sup.Heartbeat.Consumer do
  use GenStage

  require Logger

  def start_link(:ok) do
    GenStage.start_link(__MODULE__, :consumer)
  end

  def init(state) do
    {:consumer, state, subscribe_to: [{Sup.Heartbeat.Ingest, max_demand: 10}]}
  end

  def handle_events(_event, _from, state) do
    Logger.info("here")
    {:noreply, [], state}
  end
end
