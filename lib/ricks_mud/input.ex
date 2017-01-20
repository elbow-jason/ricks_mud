defmodule RicksMud.Input do

  @any_whitespace_regex ~r/\s/

  def parse(input) when input |> is_binary do
    case validate(input) do
      :ok ->
        parts =
          input
          |> strip_spacing
          |> to_parts
        {:ok, parts}
      err ->
        err
    end
  end

  defp validate(input) do
    cond do
      input == "\r\n"             -> {:invalid, :empty}
      !String.printable?(input)   -> {:invalid, :unsafe}
      String.length(input) > 162  -> {:invalid, :too_long} #160 + 2 for \r\n
      true -> :ok
    end
  end

  defp strip_spacing(input) when is_binary(input) do
    Regex.replace(@any_whitespace_regex, input, " ")
    |> String.strip
  end

  defp to_parts(input) when is_binary(input) do
    input
    |> String.split(" ")
  end

end
