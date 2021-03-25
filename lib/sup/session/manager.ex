defmodule Sup.Session.Manager do
  use DynamicSupervisor
  alias Phoenix.PubSub
  alias Sup.Session.Viewer

  require Logger

  @ack_timeout_ms 2500

  def start_link(args),
    do: DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)

  def init(_args),
    do: DynamicSupervisor.init(strategy: :one_for_one)

  def add(session_id) do
    viewer = %Viewer{
      window_ms: 12000 * 1000,
      session_id: session_id || generate_session_id()
    }

    DynamicSupervisor.start_child(__MODULE__, {Sup.Session.Server, viewer})

    viewer
  end

  def remove(pid) do
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  def heartbeat(session_id) do
    ref = make_ref()

    PubSub.broadcast_from!(:pubsub, self(), session_id, {:heartbeat, self(), ref})

    receive do
      {:ack, ^ref} ->
        :ok
      after
        @ack_timeout_ms ->
          add(session_id)
    end
  end

  defp generate_session_id do
    Base.encode64(:crypto.strong_rand_bytes(16))
  end
end
