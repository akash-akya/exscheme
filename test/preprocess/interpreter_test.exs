defmodule Exscheme.InterpreterTest do
  use ExUnit.Case
  import Exscheme.Interpreter
  require Logger

  test "simple sexp" do
    expr = "(+ 1 3)"
    {result, _env} = interpret(expr)
    assert result == 4

    expr = "(+ 1 (* 10 20))"
    {result, _env} = interpret(expr)
    assert result == 201

    expr = "(begin (define name \"something: \\\" (+ 2 3)\") name)"
    {result, env} = interpret(expr)
    assert result == "something: \\\" (+ 2 3)"
  end

  test "begin" do
    expr = "(begin (define a 100) (define b 20) (* a b))"
    {result, _env} = interpret(expr)
    assert result == 2000
  end

  test "fact" do
    expr = "(begin (define fact (lambda (n) (if (< n 2) 1 (* n (fact (- n 1)))))) (fact 4))"
    {result, _env} = interpret(expr)
    assert result == 24
  end

  test "nested function" do
    expr = "(begin (define higher (lambda (x) (lambda (y) (+ x y)))) ((higher 20) 10))"
    {result, _env} = interpret(expr)
    assert result == 30
  end

  test "define" do
    expr = "(begin (define num 10) num)"
    {result, _env} = interpret(expr)
    assert result == 10

    expr = "(begin (define num (+ 10 5)) num)"
    {result, _env} = interpret(expr)
    assert result == 15
  end

  test "set" do
    expr = "(begin (define num 10) (set! num 1) num)"
    {result, _env} = interpret(expr)
    assert result == 1

    expr = "(begin (define num 10) (set! num (+ num 1)) num)"
    {result, _env} = interpret(expr)
    assert result == 11

    expr = """
    (begin
      (define num 20)
      (define increment
        (lambda () (set! num (+ num 1))))
      (increment)
      num)
    """

    {result, _env} = interpret(expr)
    assert result == 21
  end

  test "lambda" do
    expr = "(begin (define (a x) (+ 1 x)) (a 30))"
    {result, _env} = interpret(expr)
    assert result == 31
  end

  test "if" do
    expr = "(if (> 10 5) 1 2)"
    {result, _env} = interpret(expr)
    assert result == 1

    expr = "(if (< 10 5) 1 2)"
    {result, _env} = interpret(expr)
    assert result == 2
  end

  test "cond" do
    expr = "(cond ((= 2 1) 1) ((= 2 2) 2))"
    {result, _env} = interpret(expr)
    assert result == 2

    expr = "(cond ((= 1 1) 1) ((= 2 2) 2))"
    {result, _env} = interpret(expr)
    assert result == 1

    expr = "(cond ((= 0 1) 1) ((= 0 2) 2) (else 3))"
    {result, _env} = interpret(expr)
    assert result == 3
  end
end
