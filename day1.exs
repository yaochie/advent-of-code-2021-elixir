defmodule Day1 do
  def part1([first, second | tail], acc) do
    if second > first do
      part1([second | tail], acc + 1)
    else
      part1([second | tail], acc)
    end
  end

  def part1([_last | []], acc) do
    IO.puts(acc)
  end

  def part2([first, second, third | tail]) do
    part2_rec(tail, {first, second, third}, 0)
  end

  defp part2_rec([head | tail], {first, second, third}, acc) do
    old_sum = first + second + third
    new_sum = second + third + head

    if new_sum > old_sum do
      part2_rec(tail, {second, third, head}, acc + 1)
    else
      part2_rec(tail, {second, third, head}, acc)
    end
  end

  defp part2_rec([], _, acc) do
    IO.puts(acc)
  end
end

values =
  File.read!("inputs/day1.txt")
  |> String.trim_trailing()
  |> String.split("\n")
  |> Enum.map(fn x -> String.to_integer(x) end)

Day1.part1(values, 0)
Day1.part2 values
