defmodule ExBees.Map do
  alias ExBees.Point

  # TODO: define dynamic map size
  def start_link do
    Agent.start_link(fn -> [
      [Point.empty, Point.bee, Point.empty],
      [Point.empty, Point.empty, Point.empty],
      [Point.empty, Point.empty, Point.empty]
    ] end)
  end

  def all(map) do
    Agent.get(map, fn(m) -> m end)
  end

  def get(map, {x, y}) do
    Agent.get(map, fn(m) ->
      m
      |> Enum.at(y)
      |> Enum.at(x)
    end)
  end

  def put(map, {x, y}, entity) do
    Agent.update(map, fn(m) ->
      row = Enum.at(m, y)
      new_row = List.replace_at(row, x, entity)
      List.replace_at(m, y, new_row)
    end)
  end
end
