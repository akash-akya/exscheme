defmodule Exscheme.Core.GarbageCollector do
  alias Exscheme.Core.Environment, as: Env
  alias Exscheme.Core.Memory
  alias Exscheme.Core.Procedure
  alias Exscheme.Core.Cons
  alias Exscheme.Core.HMap
  alias Exscheme.Core.Procedure

  def garbage_collect(%Env{frames: frames, memory: memory} = env, value) do
    visited = visit(frames, memory, MapSet.new())
    visited = visit(value, memory, visited)

    memory = Memory.free(memory, MapSet.to_list(visited))
    %Env{env | memory: memory}
  end

  defp visit(nil, memory, visited), do: visited

  defp visit(%Cons{} = cons, memory, visited) do
    visited = visit(cons.head, memory, visited)
    visit(cons.tail, memory, visited)
  end

  defp visit(%Procedure{env: frames}, memory, visited) do
    visit(frames, memory, visited)
  end

  defp visit(%HMap{} = map, memory, visited) do
    visited = MapSet.put(visited, map.ptr)

    Memory.get(memory, map.ptr)
    |> Enum.reduce(visited, fn {_, pointer}, visited ->
      visit(pointer, memory, visited)
    end)
  end

  defp visit(pointer, memory, visited) when is_integer(pointer) do
    if MapSet.member?(visited, pointer) do
      visited
    else
      visit(Memory.get(memory, pointer), memory, MapSet.put(visited, pointer))
    end
  end

  defp visit(pointer, memory, visited), do: visited
end
