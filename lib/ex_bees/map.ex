defmodule ExBees.Map do
  alias ExBees.Point

  def start_link(name) do
    Agent.start_link(&initialize_map/0, name: name)
  end

  def all(map) do
    Agent.get(map, fn(m) -> m end)
  end

  def allocate(map, pid, type) do
    position = pick_random_position(map)
    allocate(map, pid, type, position)
  end

  def allocate(map, pid, type, position) do
    put(map, %ExBees.Point{type: type, actor: pid, position: position})
    position
  end

  def get(map, {x, y}) do
    Agent.get(map, fn(m) ->
      m
      |> Enum.at(y)
      |> Enum.at(x)
    end)
  end

  def put(map, %{position: {x, y}} = entity) do
    Agent.update(map, fn(m) ->
      row = m |> Enum.at(y) |> List.replace_at(x, entity)
      List.replace_at(m, y, row)
    end)
  end

  def move(map, old_position, new_position) do
    point = get(map, old_position)
    put(map, %{ExBees.Point.empty | position: old_position})
    put(map, %{point | position: new_position})
  end

  def map_width do
    Application.get_env(:ex_bees, :map_width)
  end

  def map_height do
    Application.get_env(:ex_bees, :map_height)
  end

  defp pick_random_position(map) do
    position = {:rand.uniform(map_width - 1), :rand.uniform(map_height - 1)}
    case get(map, position) do
      %ExBees.Point{type: :empty} ->
        position
      _ ->
        pick_random_position(map)
    end
  end

  defp initialize_map do
    for y <- 1..map_height do
      for x <- 1..map_width, do: Point.empty({x, y})
    end
  end
end
