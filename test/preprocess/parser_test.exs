defmodule Exscheme.Preprocess.ParserTest do
  use ExUnit.Case
  import Exscheme.Preprocess.Parser

  test "parse" do
    assert [] == unwrap(parse("()"))
  end

  test "standalone sexp" do
    assert [:test] == "(test)" |> parse() |> unwrap()
    assert 1 == "1" |> parse() |> unwrap()
    assert "hello" == "\"hello\"" |> parse() |> unwrap()
    assert :func == "func" |> parse() |> unwrap()
  end

  test "symbol" do
    assert [:test] == "(test)" |> parse() |> unwrap()
    assert [:func, :arg1, :arg2] == "(func arg1 arg2)" |> parse() |> unwrap()
    assert [:func, :a100, :"a-b-c-d_AZ?-?"] == "(func a100 a-b-c-d_AZ?-?)" |> parse() |> unwrap()
  end

  test "number" do
    assert [1] == unwrap(parse("(1)"))
    assert [12.10] == unwrap(parse("(12.10)"))
  end

  test "string" do
    assert [:concat, "name", "something with space!"] ==
             "(concat \"name\" \"something with space!\")" |> parse() |> unwrap()

    assert [:test, "101 ;'p'//,4.234\t  ~"] ==
             "(test \"101 ;'p'//,4.234\t  ~\")" |> parse() |> unwrap()

    assert [:define, :x, "then it said: \"let there be light\""] ==
             "(define x \"then it said: \\\"let there be light\\\"\")" |> parse() |> unwrap()
  end

  test "nested sexp" do
    assert [:+, [:*, 10.0, 10.0], [:-, 20.0, 10.0], 10.0] ==
             "(+ (* 10 10) (- 20 10) 10)" |> parse() |> unwrap()
  end

  test "quote" do
    assert [:func, [:quote, [1, 2, 3]]] == "(func '(1 2 3))" |> parse() |> unwrap()
  end

  test "multiline" do
    exp = """
    (+
      (* 10 10)
      (- 20 10)
      10)
    """

    assert [:+, [:*, 10.0, 10.0], [:-, 20.0, 10.0], 10.0] == exp |> parse() |> unwrap()
  end

  def unwrap({:ok, [result], "", %{}, _, _}), do: result |> untag()

  def untag([]), do: []
  def untag([term | rest]), do: [untag(term) | untag(rest)]
  def untag(%Exscheme.Core.Native{value: value}), do: value
  def untag(%Exscheme.Core.Nil{}), do: nil
  def untag(term) when is_atom(term), do: term
end
