defmodule ExBees.Map.Broker do
  @segment_name ExBees.Map.Segment
  @segment_width 250
  @segment_height 250

  def all do
    GenServer.call(@segment_name, :all)
  end

  def allocate_honeycomb(pid) do
    GenServer.call(@segment_name, {:allocate_honeycomb, pid})
  end

  def allocate_bee(pid, position) do
    GenServer.call(@segment_name, {:allocate_bee, {pid, position}})
  end

  def move(old_position, new_position) do
    GenServer.call(@segment_name, {:move, old_position, new_position})
  end

  def empty?(position) do
    GenServer.call(@segment_name, {:is_empty, position})
  end

  def disallocate_actor(pid) do
    GenServer.cast(@segment_name, {:disallocate_actor, pid})
  end

  def map_width, do: Application.get_env(:ex_bees, :map_width)
  def map_height, do: Application.get_env(:ex_bees, :map_height)

  def segments_number do
    segments_number(map_height, map_height)
  end

  defp segments_number(map_height, map_height) when map_height == map_height do
    horizontal_segments(map_width) * vertical_segments(map_height)
  end

  defp horizontal_segments(width), do: roundize(width / @segment_width)
  defp vertical_segments(height), do: roundize(height / @segment_height)

  defp roundize(val) when val > 1, do: val
  defp roundize(val) when val <= 1, do: 0
end
