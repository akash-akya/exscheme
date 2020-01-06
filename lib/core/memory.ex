defmodule Exscheme.Core.Memory do
  defstruct heap: %{}, free: [], counter: 0

  alias __MODULE__
  alias Exscheme.Core.Cons
  alias Exscheme.Core.HMap
  alias Exscheme.Core.Procedure

  def init do
    malloc(%Memory{}, 20)
  end

  def put(memory, value) do
    case memory.free do
      [] ->
        put(malloc(memory, 100), value)

      [pointer | rest] ->
        heap = Map.put(memory.heap, pointer, value)
        {pointer, %Memory{memory | heap: heap, free: rest}}
    end
  end

  def get(memory, nil), do: nil

  def get(memory, pointer) do
    Map.fetch!(memory.heap, pointer)
  end

  def set(memory, nil, value), do: raise("Nil pointer")

  def set(memory, pointer, value) do
    heap = Map.update!(memory.heap, pointer, fn _ -> value end)
    %Memory{memory | heap: heap}
  end

  def malloc(memory, size) do
    free = for i <- 1..size, do: memory.counter + i
    %Memory{memory | free: free ++ memory.free, counter: memory.counter + size}
  end

  def to_native(nil, memory), do: nil

  def to_native(term, memory) do
    case term do
      %Cons{} = cons -> Cons.to_native(cons, memory)
      %HMap{} = map -> HMap.to_native(map, memory)
      %Procedure{} = proc -> "#<LAMBDA::#{inspect(proc)}>"
      {:primitive, proc} -> "#<PRIMITIVE::#{inspect(proc)}>"
      {:native, value} -> value
      pointer when is_integer(pointer) -> "#<PTR::#{pointer}>"
    end
  end

  def usage(memory) do
    Enum.count(memory.heap)
  end

  def free(memory, pointers) do
    heap = Map.drop(memory.heap, pointers)
    free = memory.free ++ pointers

    %Memory{heap: heap, free: free}
  end
end
