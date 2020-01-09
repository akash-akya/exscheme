defmodule Exscheme.Core.Memory do
  defstruct heap: %{}, free: [], counter: 0

  alias __MODULE__
  alias Exscheme.Core.Pointer
  alias Exscheme.Core.Nil

  def init do
    malloc(%Memory{}, 10)
  end

  def put(memory, value) do
    case memory.free do
      [] ->
        put(malloc(memory, 100), value)

      [pointer | rest] ->
        heap = Map.put(memory.heap, pointer, value)
        {Pointer.new(pointer), %Memory{memory | heap: heap, free: rest}}
    end
  end

  def get(_memory, %Nil{}), do: %Nil{}
  def get(memory, %Pointer{point: pointer}), do: Map.fetch!(memory.heap, pointer)

  def set(_memory, %Nil{}, _value), do: raise("Nil pointer")

  def set(memory, %Pointer{point: pointer}, value) do
    heap = Map.update!(memory.heap, pointer, fn _ -> value end)
    %Memory{memory | heap: heap}
  end

  def malloc(memory, size) do
    free = for i <- 1..size, do: memory.counter + i
    %Memory{memory | free: memory.free ++ free, counter: memory.counter + size}
  end

  def usage(memory), do: Enum.count(memory.heap)

  def retain(memory, pointers) do
    pointers = Enum.map(pointers, fn %Pointer{point: pointer} -> pointer end)
    heap = Map.take(memory.heap, pointers)
    free = Map.drop(memory.heap, pointers) |> Map.keys()

    %Memory{memory | heap: heap, free: memory.free ++ free}
  end
end
