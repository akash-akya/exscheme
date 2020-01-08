defmodule Exscheme.Interpreter do
  alias Exscheme.Preprocess.Parser
  alias Exscheme.Core.Primitives
  alias Exscheme.Core.Procedure
  alias Exscheme.Core.VM
  require Logger

  def interpret(str) do
    {:ok, [sexp], "", %{}, _, _} = Parser.parse(str)

    vm = VM.create()

    VM.with_env(nil, Primitives.primitives(), vm, fn vm ->
      eval(sexp, vm)
    end)
  end

  def eval(exp, vm) do
    case exp do
      exp when is_number(exp) or is_binary(exp) or is_nil(exp) or is_boolean(exp) ->
        {{:native, exp}, vm}

      exp when is_atom(exp) ->
        {VM.find_variable(exp, vm), vm}

      [:quote | body] ->
        {body, vm}

      [:set!, variable, value] ->
        {v, vm} = eval(value, vm)
        {nil, VM.set_variable(variable, v, vm)}

      [:define, [function_name | params] | body] ->
        {v, vm} = eval([:lambda, params | body], vm)
        {nil, VM.define(function_name, v, vm)}

      [:define, variable, value] ->
        {v, vm} = eval(value, vm)
        {nil, VM.define(variable, v, vm)}

      [:if, predicate, consequent, alternative] ->
        eval_if(predicate, consequent, alternative, &eval/2, vm)

      [:lambda, params | body] ->
        {Procedure.new(params, body, vm), vm}

      [:begin | actions] ->
        eval_sequence(actions, vm)

      [:cond | body] ->
        [[predicate | actions] | rest] = body
        eval_cond(predicate, actions, rest, vm)

      [operator | operands] ->
        {procedure, vm} = eval(operator, vm)
        {values, vm} = get_values(operands, vm)
        {value, vm} = scheme_apply(procedure, values, vm)

        vm = VM.gc(vm, value)
        {value, vm}
    end
  end

  defp get_values(operands, vm) do
    {result, vm} =
      Enum.reduce(operands, {[], vm}, fn operand, {result, vm} ->
        {value, vm} = eval(operand, vm)
        {[value | result], vm}
      end)

    {Enum.reverse(result), vm}
  end

  defp scheme_apply({:primitive, procedure}, arguments, vm) do
    {value, memory} = Primitives.apply_primitive(procedure, arguments, vm.memory)
    {value, %VM{vm | memory: memory}}
  end

  defp scheme_apply(%Procedure{} = procedure, arguments, vm) do
    params = Enum.zip(procedure.params, arguments) |> Map.new()

    VM.with_env(procedure.env, params, vm, fn vm ->
      eval_sequence(procedure.body, vm)
    end)
  end

  def to_native(exp, vm), do: Exscheme.Core.Memory.to_native(exp, vm.memory)

  defp eval_if(predicate, consequent, alternative, eval, vm) do
    case eval.(predicate, vm) do
      {{:native, true}, vm} -> eval.(consequent, vm)
      {{:native, false}, vm} -> eval.(alternative, vm)
    end
  end

  defp eval_cond(predicate, actions, rest, vm) do
    if(predicate == :else) do
      eval([:begin | actions], vm)
    else
      eval_if(predicate, [:begin | actions], [:cond | rest], &eval/2, vm)
    end
  end

  defp eval_sequence(actions, vm), do: eval_sequence(actions, vm, nil)

  defp eval_sequence([], vm, value), do: {value, vm}

  defp eval_sequence([action | remaining_actions], vm, _value) do
    {value, vm} = eval(action, vm)
    eval_sequence(remaining_actions, vm, value)
  end
end
