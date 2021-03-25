defmodule Sup.Session.Server do
  use GenServer, restart: :temporary
  alias Phoenix.PubSub
  alias Sup.Session.Viewer

  require Logger

  def start_link(viewer), do: GenServer.start_link(__MODULE__, viewer)

  def init(viewer) do
    :ok = PubSub.subscribe(:pubsub, viewer.session_id, link: true)

    {:ok, %Viewer{viewer | last_heartbeat: now_ms()}, {:continue, :watch}}
  end

  def handle_continue(:watch, viewer) do
    schedule_verification(viewer)

    {:noreply, viewer}
  end

  def handle_info(:terminate_if_timeout, viewer) do
    if now_ms() - viewer.last_heartbeat > viewer.window_ms do
      Sup.Session.Manager.remove(self())
    else
      schedule_verification(viewer)
    end

    {:noreply, viewer}
  end

  def handle_info({:heartbeat, handler, ref}, viewer) do
    Logger.info("Heartbeat #{viewer.session_id}")

    send(handler, {:ack, ref})

    {:noreply, %Viewer{viewer | last_heartbeat: now_ms()}}
  end

  def terminate(reason, _viewer) do
    Logger.info(reason)
    :ok
  end

  defp now_ms, do: System.system_time(:millisecond)

  defp schedule_verification(viewer),
    do: Process.send_after(self(), :terminate_if_timeout, viewer.window_ms)
end
