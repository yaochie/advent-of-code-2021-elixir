defmodule Day6 do
  def part1(counts) do
    total_fish = simulate(80, counts)
    IO.puts(~s(Part 1 answer: #{total_fish}))
  end

  def part2(counts) do
    total_fish = simulate(256, counts)
    IO.puts(~s(Part 2 answer: #{total_fish}))
  end

  defp simulate(0, counts) do
    # update total number of lanternfish
    counts
    |> Map.values()
    |> Enum.sum()
  end

  defp simulate(n, counts) do
    update_fn =
      fn {key, value}, acc ->
        if key == 0 do
          Map.update(acc, 6, value, &(&1 + value))
        else
          Map.update(acc, key - 1, value, &(&1 + value))
        end
      end
    new_counts = Enum.reduce(counts, %{8 => Map.get(counts, 0, 0)}, update_fn)

    simulate(n - 1, new_counts)
  end
end

numbers =
  File.read!("inputs/day6.txt")
  |> String.trim_trailing()
  |> String.split(",")
  |> Enum.map(&String.to_integer/1)

counts = Enum.reduce(
  numbers,
  Map.new(),
  fn number, acc -> Map.update(acc, number, 1, &(&1 + 1)) end
)

Day6.part1(counts)
Day6.part2(counts)
