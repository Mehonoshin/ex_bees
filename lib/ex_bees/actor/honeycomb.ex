defmodule ExBees.Honeycomb do
  use GenServer

  defstruct name: nil, bees: [], honey: 0, position: {0, 0}

  # Client API

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: name)
  end

  def bee_destroyed(server) do
    GenServer.cast(server, :bee_destroyed)
  end

  # Server callbacks

  def init(name) do
    # TODO: Use name instead of pid
    position = ExBees.Map.allocate(ExBees.Map, self(), :honeycomb)
    state = %ExBees.Honeycomb{name: name, position: position} 

    bees_number = Application.get_env(:ex_bees, :bees_per_honeycomb)
    initial_bees = for i <- 1..bees_number do
      spawn_bee(i, state)
    end

    {:ok, %{state | bees: initial_bees}}
  end

  def handle_cast(:bee_destroyed, state) do
    {:noreply, state}
  end

  defp spawn_bee(index, state) do
    "Bee.#{state.name}.#{index}" |> String.to_atom |> ExBees.Bee.start_link(state.position)
  end
end
