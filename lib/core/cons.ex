defmodule Exscheme.Core.Cons do
  alias Exscheme.Core.Memory
  alias __MODULE__

  defstruct [:head, :tail]

  def cons(a, b, memory) do
    {ptr_a, memory} = Memory.put(memory, a)
    {ptr_b, memory} = Memory.put(memory, b)

    {%Cons{head: ptr_a, tail: ptr_b}, memory}
  end

  def car(%Cons{head: ptr}, memory), do: Memory.get(memory, ptr)
  def cdr(%Cons{tail: ptr}, memory), do: Memory.get(memory, ptr)

  def set_car!(%Cons{head: ptr_a}, a, memory) do
    Memory.set(memory, ptr_a, a)
  end

  def set_cdr!(%Cons{tail: ptr_b}, b, memory) do
    Memory.set(memory, ptr_b, b)
  end
end

defimpl Exscheme.Core.Type, for: Exscheme.Core.Cons do
  alias Exscheme.Core.Type
  alias Exscheme.Core.Memory

  def to_native(%Exscheme.Core.Cons{head: head, tail: tail}, memory) do
    [
      Type.to_native(Memory.get(memory, head), memory)
      | Type.to_native(Memory.get(memory, tail), memory)
    ]
  end

  def collect(cons, memory, visited) do
    visited = Type.collect(cons.head, memory, visited)
    Type.collect(cons.tail, memory, visited)
  end
end
