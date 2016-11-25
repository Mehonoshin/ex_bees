defmodule ExBees.Bee do
  use GenServer

  defstruct honey: 0

  @tick_period 1000

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  # Callbacks
  
  def init(:ok) do
    {:ok, %ExBees.Bee{}}
  end

  def handle_info(:tick, state) do
    # TODO: move bee
    IO.puts "#{self()} moving"
    {:noreply, state}
  end

  defp tick() do
    Process.send_after(self(), :tick, @tick_period)
  end
end
