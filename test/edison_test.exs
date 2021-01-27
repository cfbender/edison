defmodule EdisonTest do
  use ExUnit.Case
  doctest Edison

  test "greets the world" do
    assert Edison.hello() == :world
  end
end
