defmodule Day10 do
  def part1(lines) do
    lines
    |> Enum.map(&(syntax_error_score([], &1)))
    |> Enum.sum()
  end

  defp syntax_error_score([], [head | tail]) do
    syntax_error_score([head], tail)
  end

  defp syntax_error_score([top | rest] = stack, [head | tail]) do
    case head do
      p when p in [:"(", :"[", :"{", :"<"] ->
        syntax_error_score([head | stack], tail)
      :")" ->
        if top == :"(" do
          syntax_error_score(rest, tail)
        else
          3
        end
      :"]" ->
        if top == :"[" do
          syntax_error_score(rest, tail)
        else
          57
        end
      :"}" ->
        if top == :"{" do
          syntax_error_score(rest, tail)
        else
          1197
        end
      :">" ->
        if top == :"<" do
          syntax_error_score(rest, tail)
        else
          25137
        end
    end
  end

  defp syntax_error_score(_stack, []) do
    # either incomplete or done
    0
  end

  def part2(lines) do
    incomplete_lines = Enum.filter(lines, fn line -> syntax_error_score([], line) == 0 end)

    incomplete_lines
    |> Enum.map(&(completion_score([], &1)))
    |> Enum.sort()
    |> Enum.at(incomplete_lines |> length() |> div(2))
  end

  defp completion_score(stack, []) do
    get_completion_score(stack, 0)
  end

  defp completion_score([], [head | tail]) do
    completion_score([head], tail)
  end

  defp completion_score([_top | rest] = stack, [head | tail]) do
    case head do
      p when p in [:"(", :"[", :"{", :"<"] ->
        completion_score([head | stack], tail)
      _ ->
        # not corrupt, so we can just remove
        completion_score(rest, tail)
    end
  end

  defp get_completion_score([], score) do
    score
  end

  defp get_completion_score([head | tail], score) do
    value =
      case head do
        :"(" -> 1
        :"[" -> 2
        :"{" -> 3
        :"<" -> 4
      end

    get_completion_score(tail, score * 5 + value)
  end
end

lines =
  File.read!("inputs/day10.txt")
  |> String.trim_trailing()
  |> String.split()
  |> Enum.map(fn line -> line |> String.graphemes() |> Enum.map(&String.to_atom/1) end)

IO.puts(~s(Part 1 answer: #{Day10.part1(lines)}))
IO.puts(~s(Part 2 answer: #{Day10.part2(lines)}))
