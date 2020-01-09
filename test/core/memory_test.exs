defmodule Exscheme.Core.MemoryTest do
  use ExUnit.Case
  alias Exscheme.Core.Memory
  alias Exscheme.Core.Pointer

  test "put" do
    {ptr, memory} = Memory.put(%Memory{}, 10)
    assert memory.heap[ptr.point] == 10
  end

  test "get" do
    memory = %Memory{heap: %{10 => "test"}}
    assert Memory.get(memory, Pointer.new(10)) == "test"
  end

  test "set" do
    {%Pointer{} = ptr, memory} = Memory.put(%Memory{}, 10)
    assert memory.heap[ptr.point] == 10

    memory = Memory.set(memory, ptr, 20)
    assert memory.heap[ptr.point] == 20
  end

  test "malloc" do
    memory = Memory.malloc(%Memory{}, 10)
    assert memory.free == Enum.to_list(1..10)

    memory = Memory.malloc(memory, 10)
    assert memory.counter == 20
    assert Enum.sort(memory.free) == Enum.to_list(1..20)
  end
end
