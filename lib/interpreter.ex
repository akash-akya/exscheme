defmodule Exscheme.Interpreter do
  alias Exscheme.Preprocess.Parser
  alias Exscheme.Core.Primitives
  alias Exscheme.Core.Procedure
  alias Exscheme.Core.Predicate
  alias Exscheme.Core.Cons
  alias Exscheme.Core.GarbageCollector, as: GC
  alias Exscheme.Core.Environment, as: Env
  require Logger

  def interpret(str) do
    env = Env.create()

    str
    |> Parser.parse()
    |> eval(Env.extend_env(env, Primitives.get_primitives()))
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
        {v, env} = eval([:lambda, params | body], env)
        {:ok, Env.define(function_name, v, env)}

      [:define, variable, value] ->
        {v, env} = eval(value, env)
        {:ok, Env.define(variable, v, env)}

      [:if, predicate, consequent, alternative] ->
        Predicate.eval_if(predicate, consequent, alternative, &eval/2, env)

      [:lambda, params | body] ->
        {Procedure.new(params, body, env), env}

      [:begin | actions] ->
        eval_sequence(actions, env)

      [:cond | body] ->
        [[predicate | actions] | rest] = body
        eval_cond(predicate, actions, rest, env)

      [operator | operands] ->
        # Exscheme.Core.Cons.to_native(env.frames, env.memory)
        # |> IO.inspect()

        {procedure, env} = eval(operator, env)
        Env.define(arg, value, env)
        {value, env} = scheme_apply(procedure, operands, env)
        # env = GC.garbage_collect(env, value)
        {value, env}
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

  def scheme_apply({:primitive, procedure}, operands, env) do
    env = Env.extend_env(env)

    env =
      operands
      |> Enum.reduce(env, fn exp, env ->
        {value, env} = eval(exp, env)
        Env.define(arg, value, env)
      end)

    {value, memory} = Primitives.apply_primitive(procedure, values, env.memory)
    {value, %Env{env | memory: memory}}
  end

  def scheme_apply(%Procedure{} = procedure, operands, env) do
    env = Env.extend_env(env, %{}, procedure.env)

    env =
      Enum.zip(procedure.params, operands)
      |> Enum.reduce(env, fn {arg, exp}, env ->
        {value, env} = eval(exp, env)
        Env.define(arg, value, env)
      end)

    eval_sequence(procedure.body, env)
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
