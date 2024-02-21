defmodule ProjectTest do
  use ExUnit.Case
  doctest Project

  test "greets the world" do
    assert Project.hello() == :world
  end
end
