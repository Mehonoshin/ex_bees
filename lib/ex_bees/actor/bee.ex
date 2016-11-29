defmodule ExBees.Bee do
  use GenServer

  defstruct name: nil, honey: 0, position: {0, 0}

  @tick_period 1000
  @directions [:left_up, :up, :right_up, :left, :right, :left_down, :down, :right_down]

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
    move(state)
    tick()
    {:noreply, state}
  end

  defp move(state) do
    movement = Enum.at(@directions, pick_direction - 1)
    IO.puts "#{state.name} moving, move to #{inspect movement}"
  end

  defp tick() do
    Process.send_after(self(), :tick, @tick_period)
  end

  defp pick_direction do
    @directions |> Enum.count |> :rand.uniform
  end
end
