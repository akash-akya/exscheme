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

  def set_car!(%Cons{head: ptr_a, tail: ptr_b}, a, memory) do
    Memory.set(memory, ptr_a, a)
  end

  def set_cdr!(%Cons{head: ptr_a, tail: ptr_b}, b, memory) do
    Memory.set(memory, ptr_b, b)
  end

  def to_native(%Cons{head: head, tail: tail} = cons, memory) do
    [
      Memory.to_native(Memory.get(memory, head), memory)
      | Memory.to_native(Memory.get(memory, tail), memory)
    ]
  end
end
