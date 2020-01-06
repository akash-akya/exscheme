defmodule Exscheme.Core.Primitives do
  alias Exscheme.Core.Cons

  def apply_primitive(:car, [cons], memory), do: {Cons.car(cons, memory), memory}

  def apply_primitive(:cdr, [cons], memory), do: {Cons.cdr(cons, memory), memory}

  def apply_primitive(:cons, [a, b], memory), do: Cons.cons(a, b, memory)

  def apply_primitive(:null?, [term], memory), do: {is_nil(term), memory}

  def apply_primitive(oper, arguments, memory) do
    {apply(Kernel, oper, arguments), memory}
  end

  def get_primitives() do
    %{
      car: {:primitive, :car},
      cdr: {:primitive, :cdr},
      cons: {:primitive, :cons},
      +: {:primitive, :+},
      -: {:primitive, :-},
      *: {:primitive, :*},
      >: {:primitive, :>},
      <: {:primitive, :<},
      =: {:primitive, :==},
      null?: {:primitive, :null}
    }
  end
end
