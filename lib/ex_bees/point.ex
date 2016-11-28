defmodule ExBees.Point do
  defstruct type: :empty, actor: nil, position: {0, 0}

  def empty do
    %ExBees.Point{}
  end

  def empty(position) do
    %ExBees.Point{position: position}
  end

  def bee do
    %ExBees.Point{type: :bee}
  end

  def point do
    %ExBees.Point{type: :honeycomb}
  end
end
