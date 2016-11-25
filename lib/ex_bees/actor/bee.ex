defmodule ExBees.Bee do
  use GenServer

  defstruct name: nil, honey: 0

  @tick_period 1000

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: name)
  end

  # Callbacks
  
  def init(name) do
    tick()
    {:ok, %ExBees.Bee{name: name}}
  end

  def handle_info(:tick, state) do
    # TODO: move bee
    IO.puts "#{state.name} moving"
    tick()
    {:noreply, state}
  end

  defp tick() do
    Process.send_after(self(), :tick, @tick_period)
  end
end
