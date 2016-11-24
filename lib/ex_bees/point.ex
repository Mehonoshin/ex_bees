defmodule ExBees.Point do
  defstruct type: :empty, process: nil

  def empty do
    %ExBees.Point{}
  end

  def bee do
    %ExBees.Point{type: :bee}
  end
end
