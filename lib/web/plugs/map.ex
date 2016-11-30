defmodule Web.Map do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts) do
    map = ExBees.Map |> ExBees.Map.all |> prepare_map
    IO.puts "Map: #{inspect map}"
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, map)
  end

  defp prepare_map(map) do
    Poison.encode!(map)
  end
end

