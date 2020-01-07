defmodule Exscheme.Core.VM do
  require Logger
  alias Exscheme.Core.Cons
  alias Exscheme.Core.HMap
  alias Exscheme.Core.Memory
  alias __MODULE__

  defstruct memory: nil, stack: []

  def create do
    memory = Memory.init()
    %VM{memory: memory, stack: []}
  end

  def find_variable(variable, %VM{} = vm),
    do: find_variable(variable, hd(vm.stack), vm.memory)

  def find_variable(variable, nil, _) do
    raise %ArgumentError{message: "variable: #{variable} not found in the env"}
  end

  def find_variable(variable, env, memory) do
    frame = Cons.car(env, memory)

    case HMap.get(frame, variable, memory) do
      nil -> find_variable(variable, Cons.cdr(env, memory), memory)
      value -> unwrap(value)
    end
  end

  def set_variable(variable, value, %VM{} = vm) when is_atom(variable) do
    memory = set_variable(variable, value, hd(vm.stack), vm.memory)
    %VM{vm | memory: memory}
  end

  def set_variable(variable, _value, nil, _) do
    raise %ArgumentError{message: "variable: #{variable} not found in the env"}
  end

  def set_variable(variable, value, env, memory) when is_atom(variable) do
    frame = Cons.car(env, memory)

    case HMap.get(frame, variable, memory) do
      nil ->
        set_variable(variable, value, Cons.cdr(env, memory), memory)

      _ ->
        HMap.put(frame, variable, wrap(value), memory)
    end
  end

  def define(name, value, %VM{memory: memory, stack: stack} = vm) do
    env = hd(stack)
    frame = Cons.car(env, vm.memory)
    memory = HMap.put(frame, name, wrap(value), memory)
    memory = Cons.set_car!(env, frame, memory)
    %VM{vm | memory: memory}
  end

  def gc(vm, value) do
    memory = Exscheme.Core.GarbageCollector.garbage_collect([wrap(value) | vm.stack], vm.memory)
    %VM{vm | memory: memory}
  end

  def with_env(env, params, vm, callback) do
    {map, memory} = HMap.new(vm.memory)
    {env, memory} = Cons.cons(map, env, memory)

    vm =
      %VM{vm | memory: memory, stack: [env | vm.stack]}
      |> define_params(params)

    {value, vm} = callback.(vm)

    {value, %VM{vm | stack: tl(vm.stack)}}
  end

  defp define_params(vm, params) do
    Enum.reduce(params, vm, fn {variable, value}, vm -> define(variable, value, vm) end)
  end

  defp wrap({:primitive, proc}) when is_atom(proc), do: {:primitive, proc}

  defp wrap(%Exscheme.Core.Procedure{} = term), do: term

  defp wrap(%Exscheme.Core.Cons{} = term), do: term

  defp wrap(%Exscheme.Core.HMap{} = term), do: term

  defp wrap(term) when is_number(term) or is_nil(term) or is_binary(term) or is_boolean(term),
    do: {:native, term}

  defp unwrap({:primitive, proc}) when is_atom(proc), do: {:primitive, proc}

  defp unwrap(%Exscheme.Core.Cons{} = term), do: term

  defp unwrap(%Exscheme.Core.HMap{} = term), do: term

  defp unwrap(%Exscheme.Core.Procedure{} = term), do: term

  defp unwrap({:native, term}), do: term
end
