defmodule ExBees.Map.Supervisor do
  use Supervisor

  def start_link(name) do
    Supervisor.start_link(__MODULE__, :ok, name: name)
  end

  def init(:ok) do
    children = [
      supervisor(ExBees.Map.SegmentsSupervisor, [ExBees.Map.SegmentsSupervisor])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
