defmodule Sup.Heartbeat.Consumer do
  use GenStage

  def start_link(:ok) do
    GenStage.start_link(__MODULE__, :consumer)
  end

  def init(state) do
    {:consumer, state, subscribe_to: [{Sup.Heartbeat.Ingest, max_demand: 100}]}
  end

  def handle_events(events, _from, state) do
    for n <- events do
      IO.puts("Processing")
      IO.puts(n)
    end

    :timer.sleep(100)
    {:noreply, [], state}
  end
end
