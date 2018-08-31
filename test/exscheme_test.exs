defmodule ExschemeTest do
  use ExUnit.Case
  doctest Exscheme

  test "greets the world" do
    assert Exscheme.hello() == :world
  end
end
