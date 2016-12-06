defmodule ExBees.SocketHandler do
  @behaviour :cowboy_websocket_handler

  def init(_, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  @timeout 60000 # terminate if no activity for one minute

  #Called on websocket connection initialization.
  def websocket_init(_type, req, _opts) do
    state = %{}
    {:ok, req, state, @timeout}
  end
  
  # Handle other messages from the browser - don't reply
  def websocket_handle({:text, "map"}, req, state) do
    tick(req)
    {:reply, {:text, map_json}, req, state}
  end

  # Format and forward elixir messages to client
  def websocket_info(message, req, state) do
    tick(req)
    {:reply, {:text, map_json}, req, state}
  end

  # No matter why we terminate, remove all of this pids subscriptions
  def websocket_terminate(_reason, _req, _state) do
    :ok
  end

  defp map_json do
    ExBees.Map
    |> ExBees.Map.all
    |> List.flatten
    |> Enum.reject(fn(p) -> p.type == :empty end)
    |> Poison.encode!
  end

  defp tick(req) do
    period = Application.get_env(:ex_bees, :tick_period)
    Process.send_after(self(), :tick, period)
  end
end
