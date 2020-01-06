defmodule Exscheme.Core.HMap do
  alias Exscheme.Core.Memory
  alias __MODULE__

  defstruct ptr: %{}

  def new(memory) do
    {ptr, memory} = Memory.put(memory, %{})
    {%HMap{ptr: ptr}, memory}
  end

  def put(map, key, value, memory) do
    data = Memory.get(memory, map.ptr)

    case data[key] do
      nil ->
        {ptr_a, memory} = Memory.put(memory, value)
        Memory.set(memory, map.ptr, Map.put(data, key, ptr_a))

      key_ptr ->
        Memory.set(memory, key_ptr, value)
    end
  end

  def get(map, key, memory) do
    data = Memory.get(memory, map.ptr)

    case Map.get(data, key) do
      nil -> nil
      pointer -> Memory.get(memory, pointer)
    end
  end

  def delete(map, key, memory) do
    data = Memory.get(memory, map.ptr)
    Memory.set(memory, map.ptr, Map.delete(data, key))
  end

  def to_native(%HMap{ptr: pointer}, memory) do
    Memory.get(memory, pointer)
    |> Enum.map(fn {key, pointer} ->
      {key, Memory.to_native(Memory.get(memory, pointer), memory)}
    end)
    |> Map.new()
  end
end
