defmodule ExBees.Bee do
  use GenServer

  defstruct name: nil, honey: 0, position: {0, 0}

  @tick_period 1000
  @directions [:left_up, :up, :right_up, :left, :right, :left_down, :down, :right_down]
  @bee_step 10

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

  defp move(%{position: old_position} = state) do
    movement = Enum.at(@directions, pick_direction - 1)

    new_position = gen_new_position(old_position, movement)
    state = case legal_position?(new_position) do
      true ->
        ExBees.Map.move(ExBees.Map, old_position, new_position)
        %{state | position: new_position}
      false ->
        state
    end
  end

  defp gen_new_position({x, y}, :left_up) do
    {x - bee_step, y - bee_step}
  end

  defp gen_new_position({x, y}, :up) do
    {x, y - bee_step}
  end

  defp gen_new_position({x, y}, :right_up) do
    {x + bee_step, y - bee_step}
  end

  defp gen_new_position({x, y}, :left) do
    {x - bee_step, y}
  end

  defp gen_new_position({x, y}, :right) do
    {x + bee_step, y}
  end

  defp gen_new_position({x, y}, :left_down) do
    {x - bee_step, y + bee_step}
  end

  defp gen_new_position({x, y}, :down) do
    {x, y + bee_step}
  end

  defp gen_new_position({x, y}, :right_down) do
    {x + bee_step, y + bee_step}
  end

  defp legal_position?({x, y}) do
    x >= 0 && x < ExBees.Map.map_width && y >= 0 && y < ExBees.Map.map_height && ExBees.Map.empty?(ExBees.Map, {x, y})
  end

  defp tick() do
    Process.send_after(self(), :tick, @tick_period)
  end

  defp pick_direction do
    @directions |> Enum.count |> :rand.uniform
  end

  defp bee_step do
    @bee_step
  end
end
