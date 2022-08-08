defmodule CraqTest do
  use ExUnit.Case
  doctest Craq

  test "greets the world" do
    assert Craq.hello() == :world
  end
end
