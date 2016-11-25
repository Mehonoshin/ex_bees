defmodule ExBees.WorldSupervisor do
  use Supervisor

  def start_link(name) do
    Supervisor.start_link(__MODULE__, :ok, name: name)
  end

  def init(:ok) do
    children = [
      worker(ExBees.Map, [ExBees.Map]),
      worker(ExBees.HoneycombRegistry, [ExBees.HoneycombRegistry])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
