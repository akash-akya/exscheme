defmodule Exscheme.Core.Primitive do
  defstruct [:function]
  alias Exscheme.Core.Cons
  alias Exscheme.Core.Native
  alias Exscheme.Core.Nil

  def papply(%__MODULE__{function: :car}, [cons], memory), do: {Cons.car(cons, memory), memory}

  def papply(%__MODULE__{function: :cdr}, [cons], memory), do: {Cons.cdr(cons, memory), memory}

  def papply(%__MODULE__{function: :cons}, [a, b], memory), do: Cons.cons(a, b, memory)

  def papply(%__MODULE__{function: :null?}, [%Nil{}], memory), do: {true, memory}
  def papply(%__MODULE__{function: :null?}, [_], memory), do: {false, memory}

  def papply(%__MODULE__{function: function}, arguments, memory) do
    arguments = Enum.map(arguments, &Native.untag(&1))

    case apply(Kernel, function, arguments) do
      nil -> {%Nil{}, memory}
      result -> {Native.tag(result), memory}
    end
  end

  def primitives() do
    %{
      car: %__MODULE__{function: :car},
      cdr: %__MODULE__{function: :cdr},
      cons: %__MODULE__{function: :cons},
      +: %__MODULE__{function: :+},
      -: %__MODULE__{function: :-},
      *: %__MODULE__{function: :*},
      >: %__MODULE__{function: :>},
      <: %__MODULE__{function: :<},
      =: %__MODULE__{function: :==},
      null?: %__MODULE__{function: :null}
    }
  end
end

defimpl Exscheme.Core.Type, for: Exscheme.Core.Primitive do
  def to_native(proc, _memory), do: "#<LAMBDA::#{inspect(proc)}>"
end
