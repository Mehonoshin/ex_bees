defmodule ExBees.Map do
  use GenServer
  alias ExBees.Point

  @ets_table_name :exbees_actors

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

  def map_width, do: Application.get_env(:ex_bees, :map_width)
  def map_height, do: Application.get_env(:ex_bees, :map_height)

  # Callbacks
  
  def init(_) do
    :ets.new(@ets_table_name, [:named_table, :set, :protected])
    {:ok, []}
  end

  def handle_call(:all, _from, state) do
    {:reply, all_points, state}
  end

  def handle_call({:allocate_honeycomb, pid}, _from, state) do
    Process.monitor(pid)
    point = %ExBees.Point{type: :honeycomb, actor: pid, position: pick_random_position}
    put(point)
    {:reply, point.position, state}
  end

  def handle_call({:allocate_bee, {pid, honeycomb_position}}, _from, state) do
    Process.monitor(pid)
    case select_spawn_point(honeycomb_position) do
      {x, y} = position ->
        put(%ExBees.Point{type: :bee, actor: pid, position: position})
        {:reply, position, state}
      :error ->
        {:reply, :error, state}
    end
  end

  def handle_call({:is_empty, position}, _from, state) do
    result = is_empty?(position)
    {:reply, result, state}
  end

  def handle_call({:move, old_position, new_position}, _from, state) do
    result_position = old_position
    decision = legal_position?(new_position)

    if decision do
      result_position = new_position
      point = get(old_position)
      put(%{ExBees.Point.empty | position: old_position})
      put(%{point | position: new_position})
    end

    {:reply, result_position, state}
  end

  def handle_cast({:disallocate_actor, pid}, state) do
    IO.puts "RES: #{inspect point_by_pid(pid)}"
    case point_by_pid(pid) do
      {_, _} = position -> IO.puts "Remove point #{inspect position}"
      nil -> IO.puts "No such pid"
    end
    {:noreply, state}
  end

  def handle_info({:DOWN, ref, :process, pid, _reason}, state) do
    # TODO: probably should demonitor process
    disallocate_actor(pid)
    {:noreply, state}
  end

  defp point_by_pid(pid) do
    r = :ets.match(@ets_table_name, {:"$1", 1, :"_"})
    IO.puts "R: #{inspect r}"
    List.first(List.flatten(r))
  end

  defp all_points do
    tuple_list = :ets.tab2list(:exbees_actors)
    Enum.map(tuple_list, fn({_, _, p}) -> p end)
  end

  defp get(position) do
     case List.last(:ets.lookup(@ets_table_name, position)) do
       {_, _, entity} -> entity
       nil -> ExBees.Point.empty(position)
     end
  end

  defp put(entity) do
    :ets.insert(@ets_table_name, {entity.position, entity.actor, entity})
  end

  defp pick_random_position do
    position = {:rand.uniform(map_width - 1), :rand.uniform(map_height - 1)}
    case get(position) do
      %ExBees.Point{type: :empty} -> position
      _ -> pick_random_position
    end
  end

  defp legal_position?({x, y}) do
    x >= 0 && x < ExBees.Map.map_width && y >= 0 && y < ExBees.Map.map_height && is_empty?({x, y})
  end

  defp is_empty?(position) do
    case get(position) do
      %ExBees.Point{type: :empty} -> true
      _ -> false
    end
  end

  defp select_spawn_point(honeycomb_position) do
    spawnpoints(honeycomb_position)
    |> Enum.find(:error, fn(position) ->
      is_empty?(position)
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
