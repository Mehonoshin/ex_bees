defmodule ExBees.Honeycomb do
  require Logger
  # TODO: honeycomb seems to be a supervisor for bees
  use GenServer

  defstruct name: nil, bees: 0, honey: 0, position: {0, 0}

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: name)
  end

  def spawn_bee(pid) do
    GenServer.cast(pid, :spawn_bee)
  end

  # Callbacks

  def init(name) do
    Process.flag(:trap_exit, true)
    position = ExBees.Map.allocate_honeycomb(self())
    state = %ExBees.Honeycomb{name: name, position: position}

    spawn_bees
    {:ok, state}
  end

  def handle_cast(:spawn_bee, state) do
    index = next_bee_index(state)

    bee_name = "Bee.#{state.name}.#{index}"
    Logger.info("Spawn bee #{bee_name}")

    bee_name
    |> String.to_atom
    |> ExBees.Bee.start_link(state.position)

    {:noreply, %{state | bees: index}}
  end

  def handle_info({:EXIT, from, reason}, state) do
    Logger.info("Bee #{inspect from} dead")

    ExBees.Map.disallocate_actor(from)
    ExBees.Honeycomb.spawn_bee(self())
    {:noreply, state}
  end

  defp spawn_bees do
    bees_number = Application.get_env(:ex_bees, :bees_per_honeycomb)

    for index <- 1..bees_number do
      ExBees.Honeycomb.spawn_bee(self())
    end
  end

  defp next_bee_index(state), do: state.bees + 1
end
