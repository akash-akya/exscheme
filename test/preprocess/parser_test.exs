defmodule Exscheme.Preprocess.ParserTest do
  use ExUnit.Case
  import Exscheme.Preprocess.Parser

  test "simple sexp" do
    expr = "(function arg 100)"
    assert parse(expr) == [:function, :arg, 100]

    expr = "   (function    arg 100 ) "
    assert parse(expr) == [:function, :arg, 100]
  end

  test "sexp with sub expression" do
    expr = "(function (add 200 300) 100)"
    assert parse(expr) == [:function, [:add, 200, 300], 100]

    expr = "(function (add-test (+ 200) 300) 100 (if #t))"

    assert parse(expr) == [
             :function,
             [String.to_atom("add-test"), [:+, 200], 300],
             100,
             [:if, String.to_atom("#t")]
           ]
  end
end
