defmodule Exscheme.Core.Predicate do
  def eval_if(predicate, consequent, alternative, eval, env) do
    if is_true(eval.(predicate, env)) do
      consequent
    else
      alternative
    end
    |> eval.(env)
  end

  # def eval_cond([[predicate | actions] | rest], eval, env) do
  #   eval_if(predicate, [:begin | actions], [:cond | rest], eval, env)
  # end

  defp is_true({false, _env}), do: false

  defp is_true({true, _env}), do: true
end
