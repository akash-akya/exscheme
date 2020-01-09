defmodule Exscheme.Core.Native do
  defstruct [:value]

  def tag([value]), do: tag(value)
  def tag(value), do: %__MODULE__{value: value}
  def untag(%__MODULE__{value: value}), do: value
end

defimpl Exscheme.Core.Type, for: Exscheme.Core.Native do
  def to_native(%Exscheme.Core.Native{value: value}, _memory), do: value
end
