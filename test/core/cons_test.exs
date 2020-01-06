defmodule Exscheme.Core.ConsTest do
  use ExUnit.Case
  alias Exscheme.Core.Memory
  alias Exscheme.Core.Cons

  test "cons" do
    memory = %Memory{}
    assert {%Cons{head: ptr_a, tail: ptr_b}, memory} = Cons.cons(10, 20, memory)
    assert Memory.get(memory, ptr_a) == 10
    assert Memory.get(memory, ptr_b) == 20
  end

  test "car" do
    memory = %Memory{}
    assert {cons, memory} = Cons.cons(10, 20, memory)
    assert Cons.car(cons, memory) == 10
  end

  test "cdr" do
    memory = %Memory{}
    assert {cons, memory} = Cons.cons(10, 20, memory)
    assert Cons.cdr(cons, memory) == 20
  end

  test "set_car!" do
    memory = %Memory{}
    assert {%Cons{head: ptr_a, tail: ptr_b} = cons, memory} = Cons.cons(10, 20, memory)
    memory = Cons.set_car!(cons, 30, memory)
    assert Memory.get(memory, ptr_a) == 30
    assert Memory.get(memory, ptr_b) == 20
  end

  test "set_cdr!" do
    memory = %Memory{}
    assert {%Cons{head: ptr_a, tail: ptr_b} = cons, memory} = Cons.cons(10, 20, memory)
    memory = Cons.set_cdr!(cons, 30, memory)
    assert Memory.get(memory, ptr_a) == 10
    assert Memory.get(memory, ptr_b) == 30
  end

  test "nil" do
    memory = %Memory{}
    assert {%Cons{head: ptr_a, tail: ptr_b} = cons, memory} = Cons.cons(10, nil, memory)
    memory = Cons.set_cdr!(cons, 30, memory)
    assert Memory.get(memory, ptr_a) == 10
    assert Memory.get(memory, ptr_b) == 30
  end
end
