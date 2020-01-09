defmodule Exscheme.Core.GarbageCollector do
  alias Exscheme.Core.Memory
  alias Exscheme.Core.Procedure
  alias Exscheme.Core.Cons
  alias Exscheme.Core.HMap
  alias Exscheme.Core.Procedure
  alias Exscheme.Core.Native
  alias Exscheme.Core.Pointer
  alias Exscheme.Core.Primitive
  alias Exscheme.Core.Nil

  def garbage_collect(stack, memory) do
    visited =
      Enum.reduce(stack, MapSet.new(), fn pointer, visited ->
        visit(pointer, memory, visited)
      end)

    Memory.retain(memory, visited)
  end

  defp visit(%Cons{} = cons, memory, visited) do
    visited = visit(cons.head, memory, visited)
    visit(cons.tail, memory, visited)
  end

  defp visit(%Procedure{env: env}, memory, visited) do
    visit(env, memory, visited)
  end

  defp visit(%HMap{} = map, memory, visited) do
    visited = MapSet.put(visited, map.ptr)

    Memory.get(memory, map.ptr)
    |> Enum.reduce(visited, fn {_, pointer}, visited ->
      visit(pointer, memory, visited)
    end)
  end

  defp visit(%Pointer{} = pointer, memory, visited) do
    if MapSet.member?(visited, pointer) do
      visited
    else
      visit(Memory.get(memory, pointer), memory, MapSet.put(visited, pointer))
    end
  end

  defp visit(%Native{}, _memory, visited), do: visited
  defp visit(%Primitive{}, _memory, visited), do: visited
  defp visit(%Nil{}, _memory, visited), do: visited
end
