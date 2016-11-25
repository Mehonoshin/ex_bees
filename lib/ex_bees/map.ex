defmodule ExBees.Map do
  alias ExBees.Point

  # TODO: define dynamic map size
  def start_link(name) do
    Agent.start_link(&initialize_map/0, name: name)
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
      row = m |> Enum.at(y) |> List.replace_at(x, entity)
      List.replace_at(m, y, row)
    end)
  end

  defp initialize_map do
    for y <- 1..map_height do
      for x <- 1..map_width do
        Point.empty
      end
    end
  end

  def map_width do
    Application.get_env(:ex_bees, :map_width)
  end

  def map_height do
    Application.get_env(:ex_bees, :map_height)
  end
end
