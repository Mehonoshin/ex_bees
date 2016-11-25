defmodule ExBees.WorldSupervisor do
  use Supervisor
  alias ExBees.Map

  def start_link(name) do
    Supervisor.start_link(__MODULE__, :ok, name: name)
  end

  def init(:ok) do
    children = [
      worker(Map, [ExBees.Map])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
