defmodule Day7 do
  def part1(positions) do
    max_position = Enum.max(positions)
    costs = Enum.map(0..max_position, fn pos -> move_cost(pos, positions) end)
    IO.puts(~s(Part 1: #{Enum.min(costs)}))
  end

  defp move_cost(new_pos, positions) do
    positions
    |> Stream.map(fn pos -> abs(pos - new_pos) end)
    |> Enum.sum()
  end

  def part2(positions) do
    max_position = Enum.max(positions)
    costs = Enum.map(0..max_position, fn pos -> move_cost2(pos, positions) end)
    IO.puts(~s(Part 2: #{Enum.min(costs)}))
  end

  defp move_cost2(new_pos, positions) do
    positions
    |> Stream.map(fn pos -> (pos - new_pos) |> abs() |> triangular_number() end)
    |> Enum.sum()
  end

  defp triangular_number(n) do
    div(n * (n + 1), 2)
  end
end

positions =
  File.read!("inputs/day7.txt")
  |> String.trim_trailing()
  |> String.split(",")
  |> Enum.map(&String.to_integer/1)

Day7.part1(positions)
Day7.part2(positions)
