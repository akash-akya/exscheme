defmodule Exscheme.Interpreter do
  alias Exscheme.Preprocess.Parser
  alias Exscheme.Core.Primitives
  alias Exscheme.Core.Procedure
  alias Exscheme.Core.Predicate
  alias Exscheme.Core.Environment, as: Env
  require Logger

  def interprete(str) do
    str
    |> Parser.parse()
    |> eval([Primitives.get_primitives()])
  end

  def eval(exp, env) when is_number(exp) or is_binary(exp), do: {exp, env}

  def eval(exp, env) when is_atom(exp), do: {Env.find_variable(exp, env), env}

  def eval([:quote | body], env), do: {body, env}

  def eval([:set!, variable, value], env) do
    {:ok, Env.set_variable(variable, &eval(value, &1), env)}
  end

  def eval([:define, [function_name | params] | body], env) do
    {:ok, Env.define(function_name, &eval([:lambda, params | body], &1), env)}
  end

  def eval([:define, variable, value], env) do
    {:ok, Env.define(variable, &eval(value, &1), env)}
  end

  def eval([:if, predicate, consequent, alternative], env) do
    Predicate.eval_if(predicate, consequent, alternative, &eval/2, env)
  end

  def eval([:lambda, params | body], env) do
    {Procedure.new(params, body, env), env}
  end

  def eval([:begin | actions], env) do
    {eval_sequence(actions, env), env}
  end

  def eval([:cond | body], env) do
    [[predicate | actions] | rest] = body
    Predicate.eval_if(predicate, [:begin | actions], [:cond | rest], &eval/2, env)
  end

  def eval([operator | operands], env) do
    {procedure, env} = eval(operator, env)
    {scheme_apply(procedure, get_values(operands, env)), env}
  end

  defp get_values(operands, env), do: Enum.map(operands, &get_value(&1, env))

  defp get_value(expr, env), do: eval(expr, env) |> elem(0)

  # apply
  def scheme_apply([:primitive, procedure], arguments) do
    Primitives.apply_primitive(procedure, arguments)
  end

  def scheme_apply(%Procedure{} = procedure, arguments) do
    frame = Env.create_frame(procedure.params, arguments)
    eval_sequence(procedure.body, [frame | procedure.env])
  end

  defp eval_sequence([], _env), do: nil

  defp eval_sequence([action | remaining_actions], env) do
    {value, env} = eval(action, env)
    eval_sequence(remaining_actions, env) || value
  end
end
