defmodule Exscheme.Core.Pointer do
  defstruct [:point]

  def new(pointer) when is_integer(pointer), do: %Exscheme.Core.Pointer{point: pointer}
end

defimpl Exscheme.Core.Type, for: Exscheme.Core.Pointer do
  alias Exscheme.Core.Memory
  def to_native(%Exscheme.Core.Pointer{point: pointer}, memory), do: Memory.get(memory, pointer)
end
