defmodule Exscheme.Core.Environment do
  require Logger
  alias Exscheme.Core.Cons
  alias Exscheme.Core.HMap
  alias Exscheme.Core.Memory
  alias __MODULE__

  defstruct memory: nil, frames: nil

  def create do
    memory = Memory.init()
    %Environment{memory: memory, frames: nil}
  end

  def find_variable(variable, %Environment{} = env),
    do: find_variable(variable, env.frames, env.memory)

  def find_variable(variable, nil, _) do
    raise %ArgumentError{message: "variable: #{variable} not found in the env"}
  end

  def find_variable(variable, frames, memory) do
    frame = Cons.car(frames, memory)

    case HMap.get(frame, variable, memory) do
      nil -> find_variable(variable, Cons.cdr(frames, memory), memory)
      value -> unwrap(value)
    end
  end

  def set_variable(variable, value, %Environment{} = env) when is_atom(variable) do
    memory = set_variable(variable, value, env.frames, env.memory)
    %Environment{env | memory: memory}
  end

  def set_variable(variable, _value, nil, _) do
    raise %ArgumentError{message: "variable: #{variable} not found in the env"}
  end

  def set_variable(variable, value, frames, memory) when is_atom(variable) do
    frame = Cons.car(frames, memory)

    case HMap.get(frame, variable, memory) do
      nil ->
        set_variable(variable, value, Cons.cdr(frames, memory), memory)

      _ ->
        HMap.put(frame, variable, wrap(value), memory)
    end
  end

  def extend_env(%Environment{memory: memory, frames: frames}) do
    {map, memory} = HMap.new(memory)
    {frames, memory} = Cons.cons(map, frames, memory)
    %Environment{frames: frames, memory: memory}
  end

  def extend_env(%Environment{} = env, %{} = data) do
    env = extend_env(env)
    Enum.reduce(data, env, fn {variable, value}, env -> define(variable, value, env) end)
  end

  def extend_env(%Environment{} = env, %{} = data, frames) do
    extend_env(%Environment{env | frames: frames}, data)
  end

  def pop_frame(%Environment{frames: frames, memory: memory}) do
    frames = Cons.cdr(frames, memory)
    %Environment{frames: frames, memory: memory}
  end

  def find_variables(params, env) do
    Enum.map(params, &find_variable(&1, env))
  end

  def define(name, value, %Environment{frames: frames, memory: memory} = env) do
    frame = Cons.car(env.frames, env.memory)
    memory = HMap.put(frame, name, wrap(value), memory)
    memory = Cons.set_car!(frames, frame, memory)
    %Environment{env | frames: frames, memory: memory}
  end

  defp wrap({:primitive, proc}) when is_atom(proc), do: {:primitive, proc}

  defp wrap(%Exscheme.Core.Procedure{} = term), do: term

  defp wrap(term) when is_number(term) or is_nil(term) or is_binary(term),
    do: {:native, term}

  defp unwrap({:primitive, proc}) when is_atom(proc), do: {:primitive, proc}

  defp unwrap(%Exscheme.Core.Procedure{} = term), do: term

  defp unwrap({:native, term}), do: term
end
