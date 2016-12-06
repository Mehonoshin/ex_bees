defmodule ExBees.Honeycomb do
  use GenServer

  defstruct name: nil, bees: [], honey: 0, position: {0, 0}

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: name)
  end

  # Callbacks

  def init(name) do
    # TODO: Use name instead of pid
    position = ExBees.Map.allocate_honeycomb(self())
    state = %ExBees.Honeycomb{name: name, position: position}

    # TODO: emit bees after start, on timer event
    bees_number = Application.get_env(:ex_bees, :bees_per_honeycomb)
    initial_bees = for i <- 1..bees_number do
      spawn_bee(i, state)
    end

    {:ok, %{state | bees: initial_bees}}
  end

  defp spawn_bee(index, state) do
    # TODO: atoms are not GCed
    "Bee.#{state.name}.#{index}"
    |> String.to_atom
    |> ExBees.Bee.start_link(state.position)
  end

  #defp tick() do
    #period = Application.get_env(:ex_bees, :tick_period)
    #Process.send_after(self(), :tick, period)
  #end

end
