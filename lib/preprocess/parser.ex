defmodule Exscheme.Preprocess.Parser do
  import NimbleParsec

  @number ?0..?9
  @allowed_char [?a..?z, ?A..?Z, ?-, ?_, ??, ?+, ?-, ?/, ?*, ?=, ?>, ?<, ?!]

  symbol =
    concat(
      utf8_string([{:not, @number} | @allowed_char], 1),
      utf8_string([@number | @allowed_char], min: 0)
    )
    |> reduce({Enum, :join, []})
    |> post_traverse({:to_atom, []})

  number =
    optional(choice([ascii_char([?+]), ascii_char([?-])]))
    |> integer(min: 1)
    |> optional(concat(ascii_string([?.], 1), integer(min: 1)))
    |> reduce({Enum, :join, []})
    |> post_traverse({:to_number, []})
    |> reduce({Exscheme.Core.Native, :tag, []})

  string =
    ignore(ascii_string([?"], 1))
    |> repeat(
      lookahead_not(ascii_char([?"]))
      |> choice([
        ~S(\") |> string() |> replace(?"),
        utf8_char([])
      ])
    )
    |> ignore(ascii_string([?"], 1))
    |> reduce({List, :to_string, []})
    |> reduce({Exscheme.Core.Native, :tag, []})

  quoted =
    ignore(ascii_string([?\'], 1))
    |> parsec(:sexp)
    |> post_traverse({:quoted, []})

  space = utf8_string([?\ , ?\t, ?\n], min: 1)

  content =
    choice([parsec(:sexp), ignore(space)])
    |> repeat()

  list =
    ignore(ascii_char([?(]))
    |> optional(content)
    |> ignore(ascii_char([?)]))
    |> reduce({List, :wrap, []})
    |> ignore(repeat(space))

  defcombinatorp(:sexp, choice([symbol, number, string, quoted, list]))

  defparsec(:parse, parsec(:sexp))

  defp quoted(_rest, [arg], context, _line, _offset) do
    {[[:quote, arg]], context}
  end

  defp to_number(_rest, [arg], context, _line, _offset) do
    {number, ""} = Float.parse(arg)
    {[number], context}
  end

  defp to_atom(_rest, ["nil"], context, _line, _offset) do
    {[%Exscheme.Core.Nil{}], context}
  end

  defp to_atom(_rest, [arg], context, _line, _offset) do
    {[String.to_atom(arg)], context}
  end
end
