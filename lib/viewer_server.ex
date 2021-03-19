defmodule ViewerServer do
  use GenServer, restart: :temporary
  alias Phoenix.PubSub

  require Logger
  def start_link(viewer) do
    GenServer.start_link(__MODULE__, viewer)
  end

  def init(viewer) do
    :ok = PubSub.subscribe(:pubsub, viewer.session)

    {:ok, viewer, {:continue, :watch}}
  end

  def handle_continue(:watch, viewer) do

    schedule_verification(viewer)

    {:noreply, viewer}
  end

  def handle_info(:terminate_if_timeouted, viewer) do
    schedule_verification(viewer)

    #Logger.info("Checking if needs terminate.. #{viewer.name}")

    {:noreply, viewer}
  end

  def handle_info({:heartbeat}, viewer) do
    Logger.info("Heartbeat #{viewer.name}")

    {:noreply, viewer}
  end

  defp process_name(viewer) do
    String.to_atom("viewer_id_#{viewer.name}_server")
  end

  defp schedule_verification(viewer) do
    Process.send_after(self(), :terminate_if_timeouted, viewer.window_ms)
  end
end
