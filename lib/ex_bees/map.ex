defmodule ExBees.Map do
  use GenServer
  alias ExBees.Point

  defstruct map: %{}, pids: %{}

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

  def disallocate_actor(pid) do
    GenServer.cast(__MODULE__, {:disallocate_actor, pid})
  end

  def map_width do
    Application.get_env(:ex_bees, :map_width)
  end

  def map_height do
    Application.get_env(:ex_bees, :map_height)
  end

  # Callbacks
  
  def init(_) do
    state = %ExBees.Map{map: initialize_map}
    {:ok, state}
  end

  def handle_call(:all, _from, state) do
    {:reply, state.map, state}
  end

  def handle_call({:allocate_honeycomb, pid}, _from, state) do
    Process.monitor(pid)
    position = pick_random_position(state)
    state = put(state, %ExBees.Point{type: :honeycomb, actor: pid, position: position})
    {:reply, position, state}
  end

  def handle_call({:allocate_bee, {pid, honeycomb_position}}, _from, state) do
    Process.monitor(pid)
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

  def handle_cast({:disallocate_actor, pid}, state) do
    point = point_by_pid(pid, state)
    if point != nil do
      state = put(state, %{ExBees.Point.empty | position: point.position})
    end
    {:noreply, state}
  end

  def handle_info({:DOWN, ref, :process, pid, _reason}, state) do
    # TODO: probably should demonitor process
    disallocate_actor(pid)
    {:noreply, state}
  end

  defp point_by_pid(pid, state) do
    state.map
    |> actors_list
    |> Enum.find(nil, fn(item) -> item.actor == pid end)
  end

  defp actors_list(map) do
    map
    |> Map.values
    |> Enum.reduce([], fn(row, acc) -> [acc | Map.values(row)] end)
    |> List.flatten
  end

  defp get(state, {x, y}) do
    state.map
    |> Map.get(y)
    |> Map.get(x)
  end

  defp put(state, %{position: {x, y}} = entity) do
    row = state.map
      |> Map.get(y)
      |> Map.update!(x, fn(point) -> entity end)
    map = Map.update!(state.map, y, fn(_) -> row end)
    %{state | map: map}
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
    Enum.reduce(0..map_height - 1, %{}, fn(y, acc) ->
      Map.put(acc, y, numered_map(map_width))
    end)
  end

  defp numered_map(size) do
    Enum.reduce(0..size - 1, %{}, fn(i, acc) ->
      Map.put(acc, i, ExBees.Point.empty)
    end)
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
