defmodule Exscheme.InterpreterTest do
  use ExUnit.Case
  import Exscheme.Interpreter
  require Logger
  alias Exscheme.Core.Cons

  test "simple sexp" do
    expr = "(+ 1 3)"
    {result, vm} = interpret(expr)
    assert to_native(result, vm) == 4

    expr = "(+ 1 (* 10 20))"
    {result, vm} = interpret(expr)
    assert to_native(result, vm) == 201

    expr = "(begin (define name \"something: \\\" (+ 2 3)\") name)"
    {result, vm} = interpret(expr)
    assert to_native(result, vm) == "something: \" (+ 2 3)"
  end

  test "begin" do
    expr = "(begin (define a 100) (define b 20) (* a b))"
    {result, vm} = interpret(expr)
    assert to_native(result, vm) == 2000
  end

  test "fact" do
    expr = "(begin (define fact (lambda (n) (if (< n 2) 1 (* n (fact (- n 1)))))) (fact 4))"
    {result, vm} = interpret(expr)
    assert to_native(result, vm) == 24
  end

  test "closure" do
    expr = """
    (begin
      (define create-adder
        (lambda (num)
          (lambda (n) (+ num n))))
      (define adder-2 (create-adder 2))
      (adder-2 10))
    """

    {result, vm} = interpret(expr)
    assert to_native(result, vm) == 12

    expr = """
    (begin
      (define counter
        (lambda (num)
          (lambda (n) (set! num (+ num n)) num)))
      (define c (counter 2))
      (c 10)
      (c 10))
    """

    {result, vm} = interpret(expr)
    assert to_native(result, vm) == 22
  end

  test "nested function" do
    expr = """
    (begin
      (define higher
        (lambda (x) (lambda (y) (+ x y))))
      ((higher 20) 10))
    """

    {result, vm} = interpret(expr)
    assert to_native(result, vm) == 30
  end

  test "define" do
    expr = "(begin (define num 10) num)"
    {result, vm} = interpret(expr)
    assert to_native(result, vm) == 10

    expr = "(begin (define num (+ 10 5)) num)"
    {result, vm} = interpret(expr)
    assert to_native(result, vm) == 15
  end

  test "set" do
    expr = "(begin (define num 10) (set! num 1) num)"
    {result, vm} = interpret(expr)
    assert to_native(result, vm) == 1

    expr = "(begin (define num 10) (set! num (+ num 1)) num)"
    {result, vm} = interpret(expr)
    assert to_native(result, vm) == 11

    expr = """
    (begin
      (define num 20)
      (define increment
        (lambda () (set! num (+ num 1))))
      (increment)
      num)
    """

    {result, vm} = interpret(expr)
    assert to_native(result, vm) == 21
  end

  test "lambda" do
    expr = "(begin (define (a x) (+ 1 x)) (a 30))"
    {result, vm} = interpret(expr)
    assert to_native(result, vm) == 31
  end

  test "if" do
    expr = "(if (> 10 5) 1 2)"
    {result, vm} = interpret(expr)
    assert to_native(result, vm) == 1

    expr = "(if (< 10 5) 1 2)"
    {result, vm} = interpret(expr)
    assert to_native(result, vm) == 2
  end

  test "cond" do
    expr = "(cond ((= 2 1) 1) ((= 2 2) 2))"
    {result, vm} = interpret(expr)
    assert to_native(result, vm) == 2

    expr = "(cond ((= 1 1) 1) ((= 2 2) 2))"
    {result, vm} = interpret(expr)
    assert to_native(result, vm) == 1

    expr = "(cond ((= 0 1) 1) ((= 0 2) 2) (else 3))"
    {result, vm} = interpret(expr)
    assert to_native(result, vm) == 3
  end

  test "cons" do
    expr = """
    (begin
      (define x nil)
      (set! x (cons 1 x))
      (set! x (cons 2 x))
      x)
    """

    {result, vm} = interpret(expr)
    assert %Cons{} = result
    assert Cons.to_native(result, vm.memory) == [2, 1 | nil]
  end

  test "garbage collection" do
    expr = """
    (begin
      (define (fact n)
        (if (< n 2)
            1
            (* n (fact (- n 1)))))
      (fact 5))
    """

    {result, vm} = interpret(expr)
    assert to_native(result, vm) == 120
    mem_usage = Exscheme.Core.Memory.usage(vm.memory)

    expr = """
    (begin
      (define (fact n)
        (if (< n 2)
            1
            (* n (fact (- n 1)))))
      (fact 10))
    """

    {_result, vm} = interpret(expr)

    assert Exscheme.Core.Memory.usage(vm.memory) == mem_usage
  end
end
