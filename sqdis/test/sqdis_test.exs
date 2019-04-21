defmodule SqdisTest do
  use ExUnit.Case
  doctest Sqdis

  test "greets the world" do
    assert Sqdis.hello() == :world
  end
end
