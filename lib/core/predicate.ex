defmodule Exscheme.Core.Predicate do
  def eval_if(predicate, consequent, alternative, eval, env) do
    case eval.(predicate, env) do
      {true, env} -> eval.(consequent, env)
      {false, env} -> eval.(alternative, env)
    end
  end

  # def eval_cond([[predicate | actions] | rest], eval, env) do
  #   eval_if(predicate, [:begin | actions], [:cond | rest], eval, env)
  # end
end
