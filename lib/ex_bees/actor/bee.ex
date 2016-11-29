defmodule ExBees.Bee do
  use GenServer

  defstruct name: nil, honey: 0, position: {0, 0}

  @tick_period 1000

  def start_link(name, position) do
    GenServer.start_link(__MODULE__, {name, position}, name: name)
  end

  # Callbacks
  
  def init({name, position}) do
    ExBees.Map.allocate(ExBees.Map, self(), :bee, position)
    tick()
    {:ok, %ExBees.Bee{name: name, position: position}}
  end

  def handle_info(:tick, state) do
    # TODO: move bee
    IO.puts "#{state.name} moving, position is: #{inspect state.position}"
    tick()
    {:noreply, state}
  end

  defp tick() do
    Process.send_after(self(), :tick, @tick_period)
  end
end
