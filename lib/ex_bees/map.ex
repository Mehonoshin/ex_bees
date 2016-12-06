defmodule ExBees.Map do
  use GenServer
  alias ExBees.Point

  def start_link(name) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  def all do
    GenServer.call(__MODULE__, :all)
  end

  def allocate(pid, type) do
    GenServer.call(__MODULE__, {:allocate, {pid, type}})
  end

  def allocate(pid, type, position) do
    GenServer.cast(__MODULE__, {:allocate, {pid, type, position}})
  end

  def move(old_position, new_position) do
    GenServer.cast(__MODULE__, {:move, old_position, new_position})
  end

  def empty?(position) do
    GenServer.call(__MODULE__, {:is_empty, position})
  end

  def map_width do
    Application.get_env(:ex_bees, :map_width)
  end

  def map_height do
    Application.get_env(:ex_bees, :map_height)
  end

  # Callbacks
  
  def init(_) do
    state = initialize_map
    {:ok, state}
  end

  def handle_call(:all, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:allocate, {pid, type}}, _from, state) do
    position = pick_random_position(state)
    state = put(state, %ExBees.Point{type: type, actor: pid, position: position})
    {:reply, position, state}
  end

  def handle_call({:is_empty, position}, _from, state) do
    result = empty?(state, position)
    {:reply, result, state}
  end

  def handle_cast({:move, old_position, new_position}, state) do
    if legal_position?(state, new_position) do
      point = get(state, old_position)
      state = put(state, %{ExBees.Point.empty | position: old_position})
      state = put(state, %{point | position: new_position})
    end
    {:noreply, state}
  end

  def handle_cast({:allocate, {pid, type, position}}, state) do
    state = put(state, %ExBees.Point{type: type, actor: pid, position: position})
    {:noreply, state}
  end

  defp get(map, {x, y}) do
    map
    |> Enum.at(y)
    |> Enum.at(x)
  end

  defp put(map, %{position: {x, y}} = entity) do
    row = map |> Enum.at(y) |> List.replace_at(x, entity)
    List.replace_at(map, y, row)
  end

  defp pick_random_position(state) do
    position = {:rand.uniform(map_width - 1), :rand.uniform(map_height - 1)}
    case get(state, position) do
      %ExBees.Point{type: :empty} ->
        position
      _ ->
        pick_random_position(state)
    end
  end

  defp legal_position?(state, {x, y}) do
    x >= 0 && x < ExBees.Map.map_width && y >= 0 && y < ExBees.Map.map_height && empty?(state, {x, y})
  end

  defp empty?(state, position) do
    case get(state, position) do
      %ExBees.Point{type: :empty} ->
        true
      _ ->
        false
    end
  end

  defp initialize_map do
    for y <- 1..map_height do
      for x <- 1..map_width, do: Point.empty({x, y})
    end
  end
end
