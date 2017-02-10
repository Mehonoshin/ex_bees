defmodule ExBees.Map.SegmentsSupervisor do
  use Supervisor

  def start_link(name) do
    Supervisor.start_link(__MODULE__, :ok, name: name)
  end

  def init(:ok) do
    children = [
      supervisor(ExBees.Map.Segment, [ExBees.Map.Segment])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
