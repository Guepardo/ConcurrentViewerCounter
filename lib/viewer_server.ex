defmodule ViewerServer do
  use GenServer, restart: :temporary
  alias Phoenix.PubSub
  alias Structs.Viewer

  require Logger

  def start_link(viewer), do: GenServer.start_link(__MODULE__, viewer)

  def init(viewer) do
    :ok = PubSub.subscribe(:pubsub, viewer.session, link: true)

    {:ok, %Viewer{viewer | last_heartbeat: now_ms()}, {:continue, :watch}}
  end

  def handle_continue(:watch, viewer) do
    schedule_verification(viewer)

    {:noreply, viewer}
  end

  def handle_info(:terminate_if_timeout, viewer) do
    if now_ms() - viewer.last_heartbeat > viewer.window_ms do
      # Logger.info("Terminate #{viewer.name} process")
      CurrentViewersDynamicSupervisor.remove_viewer(self())
    else
      # Logger.info("Check in the next #{viewer.name} verification")
      schedule_verification(viewer)
    end

    {:noreply, viewer}
  end

  def handle_info({:heartbeat}, viewer) do
    Logger.info("Heartbeat #{viewer.name}")
    {:noreply, %Viewer{viewer | last_heartbeat: now_ms()}}
  end

  def terminate(reason, _viewer) do
    # Logger.info(reason)
    :ok
  end

  defp now_ms, do: System.system_time(:millisecond)

  defp schedule_verification(viewer),
    do: Process.send_after(self(), :terminate_if_timeout, viewer.window_ms)
end
