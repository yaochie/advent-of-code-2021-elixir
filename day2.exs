defmodule Day2 do
  def parse_command(command) do
    [direction, number] = String.split(command, " ")
    {String.to_existing_atom(direction), String.to_integer(number)}
  end

  def part1(commands) do
    part1_rec(commands, 0, 0)
  end

  defp part1_rec([], position, depth) do
    IO.puts(position * depth)
  end

  defp part1_rec([head | tail], position, depth) do
    case head do
      {:forward, num} -> part1_rec(tail, position + num, depth)
      {:down, num} -> part1_rec(tail, position, depth + num)
      {:up, num} -> part1_rec(tail, position, depth - num)
    end
  end

  def part2(commands) do
    part2_rec(commands, 0, 0, 0)
  end

  defp part2_rec([], position, depth, _aim) do
    IO.puts(position * depth)
  end

  defp part2_rec([head | tail], position, depth, aim) do
    case head do
      {:forward, num} ->
        part2_rec(tail, position + num, depth + aim * num, aim)
      {:down, num} ->
        part2_rec(tail, position, depth, aim + num)
      {:up, num} ->
          part2_rec(tail, position, depth, aim - num)
    end
  end
end

# define the different types of commands, so that we can convert them
# to atoms later when parsing them.
_ = :forward
_ = :down
_ = :up

body = File.read!("inputs/day2.txt")
commands = Enum.map(String.split(String.trim_trailing(body), "\n"), fn x -> Day2.parse_command(x) end)

Day2.part1 commands
Day2.part2 commands
