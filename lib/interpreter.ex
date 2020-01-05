defmodule Exscheme.Interpreter do
  alias Exscheme.Preprocess.Parser
  alias Exscheme.Core.Primitives
  alias Exscheme.Core.Procedure
  alias Exscheme.Core.Predicate
  alias Exscheme.Core.Environment, as: Env
  require Logger

  def interpret(str) do
    env = %Env{}

    str
    |> Parser.parse()
    |> eval(Env.push_new_frame(env, Primitives.get_primitives(), env.current))
  end

  def eval(exp, env) do
    case exp do
      exp when is_number(exp) or is_binary(exp) ->
        {exp, env}

      exp when is_atom(exp) ->
        {Env.find_variable(exp, env), env}

      [:quote | body] ->
        {body, env}

      [:set!, variable, value] ->
        {v, env} = eval(value, env)
        {:ok, Env.set_variable(variable, v, env)}

      [:define, [function_name | params] | body] ->
        {:ok, Env.define(function_name, &eval([:lambda, params | body], &1), env)}

      [:define, variable, value] ->
        {:ok, Env.define(variable, &eval(value, &1), env)}

      [:if, predicate, consequent, alternative] ->
        Predicate.eval_if(predicate, consequent, alternative, &eval/2, env)

      [:lambda, params | body] ->
        {Procedure.new(params, body, env.current), env}

      [:begin | actions] ->
        eval_sequence(actions, env)

      [:cond | body] ->
        [[predicate | actions] | rest] = body
        eval_cond(predicate, actions, rest, env)

      [operator | operands] ->
        {procedure, env} = eval(operator, env)
        {values, env} = get_values(operands, env)
        scheme_apply(procedure, values, env)
    end
  end

  defp get_values(operands, env) do
    {result, env} =
      Enum.reduce(operands, {[], env}, fn operand, {result, env} ->
        {value, env} = eval(operand, env)
        {[value | result], env}
      end)

    {Enum.reverse(result), env}
  end

  def scheme_apply([:primitive, procedure], arguments, env) do
    {Primitives.apply_primitive(procedure, arguments), env}
  end

  def scheme_apply(%Procedure{} = procedure, arguments, env) do
    current = env.current
    frame_data = Enum.zip(procedure.params, arguments) |> Map.new()
    env = Env.push_new_frame(env, frame_data, procedure.current_frame)
    {value, env} = eval_sequence(procedure.body, env)
    {value, %Env{env | current: current}}
  end

  defp eval_cond(predicate, actions, rest, env) do
    if(predicate == :else) do
      eval([:begin | actions], env)
    else
      Predicate.eval_if(predicate, [:begin | actions], [:cond | rest], &eval/2, env)
    end
  end

  defp eval_sequence(actions, env), do: eval_sequence(actions, env, nil)

  defp eval_sequence([], env, value), do: {value, env}

  defp eval_sequence([action | remaining_actions], env, _value) do
    {value, env} = eval(action, env)
    eval_sequence(remaining_actions, env, value)
  end
end
