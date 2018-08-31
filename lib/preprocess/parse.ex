defmodule Exscheme.Preprocess.Parser do
  require Logger

  defp sexp?(exp) do
    String.starts_with?(exp, "(") and String.ends_with?(exp, ")")
  end

  defp remove_braces(str) do
    str
    |> String.trim_leading("(")
    |> String.trim_trailing(")")
  end

  def parse(str) when is_binary(str) do
    str = String.trim(str)

    if sexp?(str) do
      Logger.info(str)

      str
      |> remove_braces()
      |> String.split(~r{\s}, trim: true)
      |> Enum.map(&parse(&1))
    else
      str
    end
  end
end
