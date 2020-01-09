defmodule Exscheme.Core.GarbageCollector do
  alias Exscheme.Core.Memory
  alias Exscheme.Core.Type

  def garbage_collect(stack, memory) do
    visited = Enum.reduce(stack, MapSet.new(), &Type.collect(&1, memory, &2))
    Memory.retain(memory, visited)
  end
end
