defmodule ExBees.Map.BrokerTest do
  use ExUnit.Case

  test 'segments_number' do
    assert ExBees.Map.Broker.segments_number == 16.0
  end
end
