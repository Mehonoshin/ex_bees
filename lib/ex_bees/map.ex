defmodule ExBees.Map do
  alias ExBees.Point

  def start_link(name) do
    Agent.start_link(&initialize_map/0, name: name)
  end

  def all(map) do
    Agent.get(map, fn(m) -> m end)
  end

  def allocate(map, pid, type) do
    # TODO: rewrite if faster
    point = all(map)
      |> List.flatten
      |> Enum.filter(fn(point) -> point.type == :empty end)
      |> Enum.shuffle
      |> Enum.at(0)
    position = point.position
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

  defp initialize_map do
    for y <- 1..map_height do
      for x <- 1..map_width, do: Point.empty({x, y})
    end
  end

  defp map_width do
    Application.get_env(:ex_bees, :map_width)
  end

  defp map_height do
    Application.get_env(:ex_bees, :map_height)
  end
end
