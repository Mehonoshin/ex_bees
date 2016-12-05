defmodule Web.Map do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts) do
    map = ExBees.Map |> ExBees.Map.all |> prepare_map
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, map)
  end

  defp prepare_map(map) do
    map |> List.flatten |> Enum.reject(fn(p) -> p.type == :empty end) |> Poison.encode!(map)
  end
end

