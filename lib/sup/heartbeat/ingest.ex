defmodule Sup.Heartbeat.Ingest do
  use GenStage

  def start_link(_) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def ingest(event) do
    GenStage.cast(__MODULE__, {:ingest, event})
  end

  def init(:ok) do
    {:producer, {[], 0}, dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_cast({:ingest, event}, {events, pending_demand}) do
    dispatch_events({[event | events], pending_demand})
  end

  def handle_demand(incoming_demand, {events, pending_demand}) do
    dispatch_events({events, incoming_demand + pending_demand})
  end

  defp dispatch_events({events, 0}) do
    {:noreply, [], {events, 0}}
  end

  defp dispatch_events({events, demand}) do
    if length(events) == 0 do
      {:noreply, [], {events, demand}}
    else
      {:noreply, 'head', {[], demand - 1}}
    end
  end
end
