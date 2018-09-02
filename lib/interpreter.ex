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

  def eval(exp, env) do
    case exp do
      exp when is_number(exp) or is_binary(exp) ->
        {exp, env}

      exp when is_atom(exp) ->
        {Env.find_variable(exp, env), env}

      [:quote | body] ->
        {body, env}

      [:set!, variable, value] ->
        {:ok, Env.set_variable(variable, &eval(value, &1), env)}

      [:define, [function_name | params] | body] ->
        {:ok, Env.define(function_name, &eval([:lambda, params | body], &1), env)}

      [:define, variable, value] ->
        {:ok, Env.define(variable, &eval(value, &1), env)}

      [:if, predicate, consequent, alternative] ->
        Predicate.eval_if(predicate, consequent, alternative, &eval/2, env)

      [:lambda, params | body] ->
        {Procedure.new(params, body, env), env}

      [:begin | actions] ->
        {eval_sequence(actions, env), env}

      [:cond | body] ->
        [[predicate | actions] | rest] = body
        Predicate.eval_if(predicate, [:begin | actions], [:cond | rest], &eval/2, env)

      [operator | operands] ->
        {procedure, env} = eval(operator, env)
        {scheme_apply(procedure, get_values(operands, env)), env}
    end
  end

  defp get_values(operands, env), do: Enum.map(operands, &(eval(&1, env) |> elem(0)))

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
