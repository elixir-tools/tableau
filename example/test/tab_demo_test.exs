defmodule TabDemoTest do
  use ExUnit.Case
  doctest TabDemo

  test "greets the world" do
    assert TabDemo.hello() == :world
  end
end
