defmodule Exscheme.Interpreter do
  alias Exscheme.Preprocess.Parser
  require Logger

  def interprete(str) do
    str
    |> Parser.parse()
    |> eval([add_primitives()])
  end

  def eval(exp, env) when is_number(exp) or is_binary(exp), do: {exp, env}

  def eval(exp, env) when is_atom(exp), do: {lookup_env(exp, env), env}

  def eval([:quote | body], env), do: {body, env}

  def eval([:set!, variable, value], env) do
    {:ok, set_variable_value(variable, value, env)}
  end

  def eval([:define, variable, value], env) do
    {:ok, define_variable(variable, value, env)}
  end

  def eval([:if, predicate, consequent, alternative], env) do
    eval_if(predicate, consequent, alternative, env)
  end

  def eval([:lambda, params | body], env) do
    {make_procedure(params, body, env), env}
  end

  def eval([:begin | actions], env) do
    {eval_sequence(actions, env), env}
  end

  def eval([:cond | _body], _env), do: :ok

  def eval([operator | operands], env) do
    {proceduce, env} = eval(operator, env)
    {scheme_apply(proceduce, values_from_env(operands, env)), env}
  end

  # apply
  def scheme_apply([:primitive, procedure], arguments) do
    apply_primitive_proc(procedure, arguments)
  end

  def scheme_apply([:procedure, params, body, env], arguments) do
    eval_sequence(body, [create_frame(params, arguments) | env])
  end

  # primitive procedures
  defp apply_primitive_proc(:car, [first | _rest]), do: first

  defp apply_primitive_proc(:cdr, [_first | rest]), do: rest

  defp apply_primitive_proc(:cons, [first, rest]), do: [first | rest]

  defp apply_primitive_proc(:+, arguments) do
    apply(Kernel, :+, arguments)
  end

  defp apply_primitive_proc(:-, arguments), do: apply(Kernel, :-, arguments)

  defp apply_primitive_proc(:*, arguments), do: apply(Kernel, :*, arguments)

  defp apply_primitive_proc(:null?, arguments), do: is_nil(arguments)

  defp add_primitives() do
    %{
      car: [:primitive, :car],
      cdr: [:primitive, :cdr],
      cons: [:primitive, :cons],
      +: [:primitive, :+],
      -: [:primitive, :-],
      *: [:primitive, :*],
      null?: [:primitive, :null?]
    }
  end

  defp eval_if(predicate, consequent, alternative, env) do
    if is_true(eval(predicate, env)) do
      consequent
    else
      alternative
    end
    |> eval(env)
  end

  defp is_true(false), do: false

  defp is_true(true), do: true

  defp make_procedure(params, body, env) do
    [:procedure, params, body, env]
  end

  defp eval_sequence([], _env), do: nil

  defp eval_sequence([action | remaining_actions], env) do
    {value, env} = eval(action, env)
    eval_sequence(remaining_actions, env) || value
  end

  ## Environment
  defp lookup_env(variable, []) do
    Logger.error("variable: #{variable} not found in the env")
    raise ArgumentError
  end

  defp lookup_env(variable, [frame | env]) do
    if Map.has_key?(frame, variable) do
      frame[variable]
    else
      lookup_env(variable, env)
    end
  end

  defp set_variable_value(variable, _value, []) do
    Logger.error("Variable: #{variable} not found in the env!")
    raise ArgumentError
  end

  defp set_variable_value(variable, value, [frame | env]) when is_atom(variable) do
    if Map.has_key?(frame, variable) do
      {value, _env} = eval(value, [frame | env])
      [Map.put(frame, variable, value) | env]
    else
      set_variable_value(variable, value, env)
    end
  end

  defp create_frame([], []), do: %{}

  defp create_frame([param | params], [arg | args]) do
    create_frame(params, args)
    |> Map.put(param, arg)
  end

  defp values_from_env([], _env), do: []

  defp values_from_env([param | other_params], env) do
    {value, _env} = eval(param, env)
    [value | values_from_env(other_params, env)]
  end

  defp define_variable(variable, value, [frame | other_frames]) when is_atom(variable) do
    {value, _env} = eval(value, [frame | other_frames])

    [Map.put(frame, variable, value) | other_frames]
  end

  defp define_variable([variable | params], body, [frame | other_frames]) do
    {value, _env} = eval([:lambda, params, body], [frame | other_frames])

    [Map.put(frame, variable, value) | other_frames]
  end
end
