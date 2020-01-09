defmodule Exscheme.Core.HMap do
  alias Exscheme.Core.Memory
  alias Exscheme.Core.Nil
  alias __MODULE__

  defstruct ptr: %{}

  def new(memory) do
    {ptr, memory} = Memory.put(memory, %{})
    {%HMap{ptr: ptr}, memory}
  end

  def put(map, key, value, memory) do
    data = Memory.get(memory, map.ptr)

    case Map.get(data, key, :not_found) do
      :not_found ->
        {pointer, memory} = Memory.put(memory, value)
        Memory.set(memory, map.ptr, Map.put(data, key, pointer))

      key_pointer ->
        Memory.set(memory, key_pointer, value)
    end
  end

  def get(map, key, memory) do
    data = Memory.get(memory, map.ptr)

    case Map.get(data, key, :not_found) do
      :not_found -> :not_found
      pointer -> Memory.get(memory, pointer)
    end
  end

  def delete(map, key, memory) do
    data = Memory.get(memory, map.ptr)
    Memory.set(memory, map.ptr, Map.delete(data, key))
  end
end

defimpl Exscheme.Core.Type, for: Exscheme.Core.HMap do
  alias Exscheme.Core.Memory

  def to_native(%Exscheme.Core.HMap{ptr: pointer}, memory) do
    Memory.get(memory, pointer)
    |> Enum.map(fn {key, pointer} ->
      {key, Exscheme.Core.Type.to_native(Memory.get(memory, pointer), memory)}
    end)
    |> Map.new()
  end
end
