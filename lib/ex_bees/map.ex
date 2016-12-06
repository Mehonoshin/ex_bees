defmodule ExBees.Map do
  use GenServer
  alias ExBees.Point

  def start_link(name) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  def all do
    GenServer.call(__MODULE__, :all)
  end

  def allocate_honeycomb(pid) do
    GenServer.call(__MODULE__, {:allocate_honeycomb, pid})
  end

  def allocate_bee(pid, position) do
    GenServer.call(__MODULE__, {:allocate_bee, {pid, position}})
  end

  def move(old_position, new_position) do
    GenServer.call(__MODULE__, {:move, old_position, new_position})
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

  def handle_call({:allocate_honeycomb, pid}, _from, state) do
    position = pick_random_position(state)
    state = put(state, %ExBees.Point{type: :honeycomb, actor: pid, position: position})
    {:reply, position, state}
  end

  def handle_call({:allocate_bee, {pid, honeycomb_position}}, _from, state) do
    case select_spawn_point(state, honeycomb_position) do
      {x, y} = position ->
        state = put(state, %ExBees.Point{type: :bee, actor: pid, position: position})
        {:reply, position, state}
      :error ->
        {:reply, :error, state}
    end
  end

  def handle_call({:is_empty, position}, _from, state) do
    result = empty?(state, position)
    {:reply, result, state}
  end

  def handle_call({:move, old_position, new_position}, _from, state) do
    result_position = old_position
    decision = legal_position?(state, new_position)

    if decision do
      result_position = new_position
      point = get(state, old_position)
      state = put(state, %{ExBees.Point.empty | position: old_position})
      state = put(state, %{point | position: new_position})
    end

    {:reply, result_position, state}
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

  defp select_spawn_point(state, honeycomb_position) do
    spawnpoints(honeycomb_position)
    |> Enum.find(:error, fn(position) ->
      empty?(state, position)
    end)
  end

  defp spawnpoints({x, y}) do
    [
      {x - 1, y    },
      {x + 1, y    },
      {x    , y - 1},
      {x    , y + 1},
      {x - 1, y - 1},
      {x + 1, y + 1},
      {x + 1, y - 1},
      {x - 1, y + 1}
    ]
  end
end
