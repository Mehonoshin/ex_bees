defmodule ExBees.Honeycomb do
  use GenServer

  # Client API

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def bee_destroyed(server) do
    GenServer.cast(server, :bee_destroyed)
  end

  # Server callbacks

  def init(:ok) do
    {:ok, []}
  end

  def handle_cast(:bee_destroyed, state) do
    state = spawn_bee(state)
    {:noreply, state}
  end

  defp spawn_bee(state) do
    IO.puts "Spawning new bee! Bees: #{inspect state}"
  end
end
