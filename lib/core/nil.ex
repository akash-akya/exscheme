defmodule Exscheme.Core.Nil do
  defstruct []
end

defimpl Exscheme.Core.Type, for: Exscheme.Core.Nil do
  def to_native(%Exscheme.Core.Nil{}, _memory), do: nil
  def collect(_, _memory, visited), do: visited
end
