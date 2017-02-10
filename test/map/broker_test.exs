defmodule ExBees.Map.BrokerTest do
  use ExUnit.Case

  test 'case 1' do
    assert ExBees.Map.Broker.segments_number(1000, 1000) == 16
  end

  test 'case 2' do
    assert ExBees.Map.Broker.segments_number(1000, 500) == 8
  end

  test 'case 3' do
    assert ExBees.Map.Broker.segments_number(1000, 300) == 8
  end

  test 'case 4' do
    assert ExBees.Map.Broker.segments_number(300, 300) == 4
  end
end
