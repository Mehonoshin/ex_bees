defmodule ExBees.Bee do
  use GenServer

  defstruct name: nil, honey: 0, position: {0, 0}

  @directions [:left_up, :up, :right_up, :left, :right, :left_down, :down, :right_down]

  def start_link(name, position) do
    GenServer.start_link(__MODULE__, {name, position}, name: name)
  end

  # Callbacks
  
  def init({name, honeycomb_position}) do
    bee_position = allocate_on_map(honeycomb_position)
    tick()
    {:ok, %ExBees.Bee{name: name, position: bee_position}}
  end

  def handle_info(:tick, state) do
    state = move(state)
    tick()
    {:noreply, state}
  end

  defp move(%{position: old_position} = state) do
    movement = Enum.at(@directions, pick_direction - 1)
    new_position = gen_new_position(old_position, movement)

    result_position = ExBees.Map.move(old_position, new_position)
    %{state | position: result_position}
  end

  defp allocate_on_map(honeycomb_position) do
    position = ExBees.Map.allocate_bee(self(), honeycomb_position)
    case position do
      :error ->
        Process.sleep(tick_period)
        allocate_on_map(honeycomb_position)
      _ ->
        position
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
    x >= 0 && x < ExBees.Map.map_width && y >= 0 && y < ExBees.Map.map_height && ExBees.Map.empty?({x, y})
  end

  defp tick do
    Process.send_after(self(), :tick, tick_period)
  end

  defp pick_direction do
    @directions |> Enum.count |> :rand.uniform
  end

  defp bee_step do
    Application.get_env(:ex_bees, :bee_step)
  end

  defp tick_period do
    Application.get_env(:ex_bees, :tick_period)
  end
end
