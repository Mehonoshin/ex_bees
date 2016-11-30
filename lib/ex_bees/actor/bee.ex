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
    state = move(state)
    tick()
    {:noreply, state}
  end

  defp move(state) do
    movement = Enum.at(@directions, pick_direction - 1)

    position = gen_new_position(state.position, movement)
    if legal_position?(position) do
      state = %{state | position: position}
      ExBees.Map.put(ExBees.Map, state)
    end
    state
  end

  defp gen_new_position({x, y}, :left_up) do
    {x - 1, y - 1}
  end

  defp gen_new_position({x, y}, :up) do
    {x, y - 1}
  end

  defp gen_new_position({x, y}, :right_up) do
    {x + 1, y - 1}
  end

  defp gen_new_position({x, y}, :left) do
    {x - 1, y}
  end

  defp gen_new_position({x, y}, :right) do
    {x + 1, y}
  end

  defp gen_new_position({x, y}, :left_down) do
    {x - 1, y + 1}
  end

  defp gen_new_position({x, y}, :down) do
    {x, y + 1}
  end

  defp gen_new_position({x, y}, :right_down) do
    {x + 1, y + 1}
  end

  defp legal_position?({x, y}) do
    x >= 0 && x < ExBees.Map.map_width && y >= 0 && y < ExBees.Map.map_height
  end

  defp tick() do
    Process.send_after(self(), :tick, @tick_period)
  end

  defp pick_direction do
    @directions |> Enum.count |> :rand.uniform
  end
end
