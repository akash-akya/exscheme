defmodule Exscheme.Core.HMapTest do
  use ExUnit.Case
  alias Exscheme.Core.Memory
  alias Exscheme.Core.HMap

  test "put" do
    memory = %Memory{}
    assert {map, memory} = HMap.new(memory)

    memory = HMap.put(map, :test, 10, memory)
    memory = HMap.put(map, :name, "Scheme", memory)

    assert HMap.get(map, :test, memory) == 10
    assert HMap.get(map, :name, memory) == "Scheme"
  end
end
