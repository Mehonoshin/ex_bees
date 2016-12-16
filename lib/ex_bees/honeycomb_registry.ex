defmodule ExBees.HoneycombRegistry do
  use GenServer

  # API
  def start_link(name) do
    hc_number = Application.get_env(:ex_bees, :honeycombs_number)
    GenServer.start_link(__MODULE__, hc_number, name: name)
  end

  # Callbacks

  def init(hc_number) do
    state = for i <- 1..hc_number do
      # TODO: atoms are not GCed
      "Honeycomb.#{i}" |> String.to_atom |> start_honeycomb
    end
    {:ok, state}
  end

  defp start_honeycomb(name) do
    {:ok, pid} = ExBees.Honeycomb.start_link(name)
    pid
  end
end
