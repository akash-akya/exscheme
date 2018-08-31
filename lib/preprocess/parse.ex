defmodule Exscheme.Preprocess.Parser do
  require Logger

  def parse(str) when is_binary(str) do
    {:ok, tokens, _} = str |> to_charlist() |> :scheme_lexer.string()
    {:ok, sexps} = :scheme_parser.parse(tokens)
    sexps
  end
end
