defmodule Exscheme.InterpreterTest do
  use ExUnit.Case
  import Exscheme.Interpreter
  require Logger

  test "simple sexp" do
    expr = "(+ 1 3)"
    {result, _env} = interprete(expr)
    assert result == 4

    expr = "(+ 1 (* 10 20))"
    {result, _env} = interprete(expr)
    assert result == 201
  end

  test "lambda" do
    expr = "(begin (define (a x) (+ 1 x)) (a 10))"
    {result, _env} = interprete(expr)
    assert result == 11
  end

  test "begin" do
    expr = "(begin (define a 100) (define b 20) (* a b))"
    {result, _env} = interprete(expr)
    assert result == 2000
  end
end
