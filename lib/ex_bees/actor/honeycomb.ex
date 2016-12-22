defmodule ExBees.Honeycomb do
  use Supervisor

  def start_link(hc_name) do
    Supervisor.start_link(__MODULE__, hc_name, name: hc_name)
  end

  def init(hc_name) do
    # TODO: keep position at state agent
    position = ExBees.Map.allocate_honeycomb(self())

    children = for index <- 1..bees_number do
      bee_name = "Bee.#{hc_name}.#{index}" |> String.to_atom
      worker(ExBees.Bee, [bee_name, position], id: bee_name)
    end

    supervise(children, strategy: :one_for_one)
  end

  defp bees_number, do: Application.get_env(:ex_bees, :bees_per_honeycomb)
end
