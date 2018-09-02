defmodule Exscheme.Core.Environment do
  require Logger

  def find_variable(variable, []) do
    Logger.error("variable: #{variable} not found in the env")
    raise ArgumentError
  end

  def find_variable(variable, [frame | env]) do
    if Map.has_key?(frame, variable) do
      frame[variable]
    else
      find_variable(variable, env)
    end
  end

  def set_variable(variable, _eval_in_env, []) do
    Logger.error("Variable: #{variable} not found in the env!")
    raise ArgumentError
  end

  def set_variable(variable, eval_in_env, [frame | env]) when is_atom(variable) do
    if Map.has_key?(frame, variable) do
      {value, _env} = eval_in_env.([frame | env])
      [Map.put(frame, variable, value) | env]
    else
      set_variable(variable, eval_in_env, env)
    end
  end

  def create_frame([], []), do: %{}

  def create_frame([param | params], [arg | args]) do
    create_frame(params, args)
    |> Map.put(param, arg)
  end

  def find_variables(params, env) do
    Enum.map(params, &find_variable(&1, env))
  end

  def define(name, eval_in_env, [frame | other_frames]) do
    {value, _env} = eval_in_env.([frame | other_frames])
    [Map.put(frame, name, value) | other_frames]
  end
end
