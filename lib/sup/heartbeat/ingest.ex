defmodule Sup.Heartbeat.Ingest do
  use GenStage

  def start_link(_), do: GenStage.start_link(__MODULE__, :ok, name: __MODULE__)

  def add(event), do: GenStage.cast(__MODULE__, {:add, event})

  def init(:ok), do: {:producer, {:queue.new(), 0}, dispatcher: GenStage.BroadcastDispatcher}

  def handle_cast({:add, event}, {events, pending_demand}) do
    dispatch_events({:queue.in(event, events), pending_demand}, [])
  end

  def handle_demand(incoming_demand, {events, pending_demand}),
    do: dispatch_events({events, incoming_demand + pending_demand}, [])

  defp dispatch_events({events, 0}, event_to_dispatch), do: {:noreply, event_to_dispatch, {events, 0}}

  defp dispatch_events({events, demand}, event_to_dispatch) do
    if :queue.len(events) == 0 do
      {:noreply, event_to_dispatch, {events, demand}}
    else
      {{:value, event}, events} = :queue.out(events)
      dispatch_events({events, demand - 1}, [ event | event_to_dispatch])
    end
  end
end
