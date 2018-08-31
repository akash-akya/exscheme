defmodule Exscheme.Preprocess.ParserTest do
  use ExUnit.Case
  import Exscheme.Preprocess.Parser

  test "simple sexp" do
    expr = "(function arg 100)"
    assert parse(expr) == ["function", "arg", "100"]

    expr = " (function arg 100)   "
    assert parse(expr) == ["function", "arg", "100"]

    expr = "(    function     arg \n100) "
    assert parse(expr) == ["function", "arg", "100"]

    expr = "(function arg 100)"
    assert parse(expr) == ["function", "arg", "100"]
  end

  test "sexp with sub expression" do
    expr = "(function (add 200 300) 100)"
    assert parse(expr) == ["function", ["add", "200", "300"], "100"]
  end
end
