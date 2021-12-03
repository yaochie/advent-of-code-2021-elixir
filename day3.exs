defmodule Day3 do
  def to_int_tuples(number) do
    List.to_tuple(
      Enum.map(
        String.split(number, "", trim: true),
        fn x -> String.to_integer(x) end
      )
    )
  end

  def part1(lines) do
    num_lines = length(lines)

    # Get the size of the binary number, so that we know how far to iterate.
    first_line = hd(lines)
    max_count = byte_size(first_line) - 1
    total = round(:math.pow(2, byte_size(first_line))) - 1

    counts = Enum.map(0..max_count, fn pos -> position_sum(lines, pos) end)

    gamma_rate =
      counts
      |> Enum.map(fn count -> if count > num_lines / 2 do "1" else "0" end end)
      |> Enum.join()
      |> String.to_integer(2)

    epsilon_rate = total - gamma_rate

    IO.puts(gamma_rate * epsilon_rate)
  end

  defp position_sum(lines, pos) do
    Enum.map(lines, fn line -> String.at(line, pos) |> String.to_integer() end)
    |> Enum.sum()
  end

  def part2(lines) do
    oxygen = oxygen_rating(lines, 0)
    co2 = co2_rating(lines, 0)

    IO.puts(oxygen * co2)
  end

  defp oxygen_rating([head | []], _pos) do
    String.to_integer(head, 2)
  end

  defp oxygen_rating(lines, pos) do
    # Get the most common value in the "pos" position.
    num_lines = length(lines)
    one_sum = position_sum(lines, pos)

    # Filter by the value.
    # If both values are equally common, filter by "1".
    lines = (
      if one_sum < num_lines / 2 do
        Enum.filter(lines, fn line -> String.at(line, pos) == "0" end)
      else
        Enum.filter(lines, fn line -> String.at(line, pos) == "1" end)
      end
    )

    oxygen_rating(lines, pos + 1)
  end

  defp co2_rating([head | []], _pos) do
    String.to_integer(head, 2)
  end

  defp co2_rating(lines, pos) do
    # Get the least common value in the "pos" position.
    num_lines = length(lines)
    one_sum = position_sum(lines, pos)

    # Filter by the value.
    # If both values are equally common, filter by "0".
    lines = (
      if one_sum < num_lines / 2 do
        Enum.filter(lines, fn line -> String.at(line, pos) == "1" end)
      else
        Enum.filter(lines, fn line -> String.at(line, pos) == "0" end)
      end
    )

    co2_rating(lines, pos + 1)
  end
end

lines =
  File.read!("inputs/day3.txt")
  |> String.trim_trailing()
  |> String.split("\n")

Day3.part1(lines)
Day3.part2(lines)
