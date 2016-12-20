defmodule ExBees.HoneycombSupervisor do
  use Supervisor

  def start_link(name) do
    hc_number = Application.get_env(:ex_bees, :honeycombs_number)
    Supervisor.start_link(__MODULE__, hc_number, name: name)
  end

  def init(hc_number) do
    children = for i <- 1..hc_number do
      name = String.to_atom("Honeycomb.#{i}")
      supervisor(ExBees.Honeycomb, [name])
    end

    supervise(children, strategy: :one_for_one)
  end

  def handle_info({:EXIT, from, reason}, state) do
    IO.puts "HC is down #{inspect from}"
    {:noreply, state}
  end
end
