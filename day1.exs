defmodule Day1 do
  def part1([head | tail]) do
    part1_rec(tail, head, 0)
  end

  defp part1_rec([head | tail], previous, acc) do
    if head > previous do
      part1_rec(tail, head, acc + 1)
    else
      part1_rec(tail, head, acc)
    end
  end

  defp part1_rec([], _, acc) do
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

body = File.read!("inputs/day1.txt")
values = Enum.map(String.split(String.trim_trailing(body), "\n"), fn x -> String.to_integer(x) end)

Day1.part1 values
Day1.part2 values
