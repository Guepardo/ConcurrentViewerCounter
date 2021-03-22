defmodule CurrentViewersDynamicSupervisor do
  use DynamicSupervisor
  alias Phoenix.PubSub
  alias Structs.Viewer

  require Logger

  def start_link(args),
    do: DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)

  def init(_args),
    do: DynamicSupervisor.init(strategy: :one_for_one)

  def add_viewer(name) do
    viewer = %Viewer{
      name: name,
      window_ms: 120 * 1000,
      session: Base.encode64(:crypto.strong_rand_bytes(16))
    }

    {:ok, pid} = DynamicSupervisor.start_child(__MODULE__, {ViewerServer, viewer})

    %Viewer{viewer | pid: pid}
  end

  def remove_viewer(pid) do
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  def heartbeat(session) do
    PubSub.broadcast_from!(:pubsub, self(), session, {:heartbeat})
  end
end
