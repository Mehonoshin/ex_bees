defmodule ExBees.HoneycombRegistry do
  use GenServer

  # API
  def start_link(name) do
    hc_number = Application.get_env(:ex_bees, :honeycombs_number)
    GenServer.start_link(__MODULE__, hc_number, name: name)
  end

  def create do
    GenServer.call(ExBees.HoneycombRegistry, :create_honeycomb)
  end

  # Callbacks

  def init(hc_number) do
    state = for i <- 1..hc_number do
      "Honeycomb.#{i}" |> String.to_atom |> start_honeycomb
    end
    {:ok, state}
  end

  def handle_call(:create_honeycomb, _from, state) do
    {:reply, :ok, ["Honeycomb #{Enum.count(state)}" | state]}
  end

  def handle_call(:list, state) do
    {:noreply, state, state}
  end

  defp start_honeycomb(name) do
    {:ok, pid} = ExBees.Honeycomb.start_link(name)
    pid
  end

  # TODO: add monitor here to process honeycomb crash
end
