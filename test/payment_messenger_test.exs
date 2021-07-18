defmodule PaymentMessengerTest do
  use ExUnit.Case
  doctest PaymentMessenger

  test "greets the world" do
    assert PaymentMessenger.hello() == :world
  end
end
