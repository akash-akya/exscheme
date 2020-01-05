defmodule Exscheme.Core.Environment do
  require Logger
  alias __MODULE__

  defstruct frame_map: %{}, current: nil, counter: 0

  defmodule Exscheme.Core.Environment.Frame do
    defstruct [:data, :parent]

    def get(%__MODULE__{data: data}, variable) do
      Map.fetch(data, variable)
    end

    def set(frame, variable, value) do
      %__MODULE__{frame | data: Map.put(frame.data, variable, value)}
    end
  end

  alias Exscheme.Core.Environment.Frame

  def find_variable(variable, %Environment{current: nil}) do
    raise %ArgumentError{message: "variable: #{variable} not found in the env"}
  end

  def find_variable(variable, %Environment{} = env) do
    frame = current_frame(env)

    case Frame.get(frame, variable) do
      {:ok, value} -> value
      :error -> find_variable(variable, next_frame(env))
    end
  end

  def set_variable(variable, _eval_in_env, %Environment{current: nil}) do
    raise %ArgumentError{message: "variable: #{variable} not found in the env"}
  end

  def set_variable(variable, value, %Environment{} = env) when is_atom(variable) do
    frame = current_frame(env)

    case Frame.get(frame, variable) do
      {:ok, _value} ->
        update_frame(env, variable, value)

      :error ->
        set_variable(variable, value, next_frame(env))
    end
  end

  def push_new_frame(%Environment{} = env, data, parent) do
    add_frame(env, %Frame{data: data, parent: parent})
  end

  def find_variables(params, env) do
    Enum.map(params, &find_variable(&1, env))
  end

  def define(name, eval_in_env, env) do
    {value, env} = eval_in_env.(env)
    update_frame(env, name, value)
  end

  defp current_frame(%Environment{} = env), do: env.frame_map[env.current]

  defp next_frame(%Environment{} = env) do
    frame = current_frame(env)
    %Environment{env | current: frame.parent}
  end

  defp update_frame(env, variable, value) do
    frame =
      current_frame(env)
      |> Frame.set(variable, value)

    %Environment{env | frame_map: Map.put(env.frame_map, env.current, frame)}
  end

  def add_frame(%Environment{} = env, frame) do
    current = env.counter + 1

    %Environment{
      frame_map: Map.put(env.frame_map, current, frame),
      current: current,
      counter: env.counter + 1
    }
  end
end
