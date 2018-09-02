defmodule Exscheme.Core.Primitives do
  def apply_primitive(:car, [first | _rest]), do: first

  def apply_primitive(:cdr, [_first | rest]), do: rest

  def apply_primitive(:cons, [first, rest]), do: [first | rest]

  def apply_primitive(:+, arguments) do
    apply(Kernel, :+, arguments)
  end

  def apply_primitive(:-, arguments), do: apply(Kernel, :-, arguments)

  def apply_primitive(:*, arguments), do: apply(Kernel, :*, arguments)

  def apply_primitive(:null?, arguments), do: is_nil(arguments)

  def get_primitives() do
    %{
      car: [:primitive, :car],
      cdr: [:primitive, :cdr],
      cons: [:primitive, :cons],
      +: [:primitive, :+],
      -: [:primitive, :-],
      *: [:primitive, :*],
      null?: [:primitive, :null?]
    }
  end
end
