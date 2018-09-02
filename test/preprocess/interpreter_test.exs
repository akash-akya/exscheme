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

  test "begin" do
    expr = "(begin (define a 100) (define b 20) (* a b))"
    {result, _env} = interprete(expr)
    assert result == 2000
  end

  test "define" do
    expr = "(begin (define num 10) num)"
    {result, _env} = interprete(expr)
    assert result == 10

    expr = "(begin (define num (+ 10 5)) num)"
    {result, _env} = interprete(expr)
    assert result == 15
  end

  test "set" do
    expr = "(begin (define num 10) (set! num 1) num)"
    {result, _env} = interprete(expr)
    assert result == 1

    expr = "(begin (define num 10) (set! num (+ num 1)) num)"
    {result, _env} = interprete(expr)
    assert result == 11
  end

  test "lambda" do
    expr = "(begin (define (a x) (+ 1 x)) (a 30))"
    {result, _env} = interprete(expr)
    assert result == 31
  end

  test "if" do
    expr = "(if (> 10 5) 1 2)"
    {result, _env} = interprete(expr)
    assert result == 1

    expr = "(if (< 10 5) 1 2)"
    {result, _env} = interprete(expr)
    assert result == 2
  end

  test "cond" do
    expr = "(cond ((= 2 3) 1) ((= 1 1) 2))"
    {result, _env} = interprete(expr)
    assert result == 2

    expr = "(cond ((= 2 2) 1) ((= 1 1) 2))"
    {result, _env} = interprete(expr)
    assert result == 1
  end
end
