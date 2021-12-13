defmodule Day13 do
  def parse_coords(line) do
    [x, y] =
      line
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    {x, y}
  end

  def parse_instruction(line) do
    [type, pos] =
      line
      |> String.split()
      |> Enum.at(2)
      |> String.split("=")

    {String.to_atom(type), String.to_integer(pos)}
  end

  def part1(dot_set, [fold_line | _rest]) do
    # only do the first fold
    folded = fold(dot_set, fold_line)

    MapSet.size(folded)
  end

  defp fold(dot_set, {:x, line_x}) do
    # fold from right to left
    # first, filter out all positions to the right of the line
    to_move = Enum.filter(dot_set, fn {x, _y} -> x > line_x end)

    # then put them in the new position
    Enum.reduce(
      to_move,
      dot_set,
      fn {x, y} = pos, acc ->
        acc
        |> MapSet.delete(pos)
        |> MapSet.put({line_x - (x - line_x), y})
      end
    )
  end

  defp fold(dot_set, {:y, line_y}) do
    # fold from bottom to top
    to_move = Enum.filter(dot_set, fn {_x, y} -> y > line_y end)

    Enum.reduce(
      to_move,
      dot_set,
      fn {x, y} = pos, acc ->
        acc
        |> MapSet.delete(pos)
        |> MapSet.put({x, line_y - (y - line_y)})
      end
    )
  end

  def part2(dot_set, fold_lines) do
    folded = Enum.reduce(fold_lines, dot_set, fn fold_line, acc -> fold(acc, fold_line) end)
    display_dot_set(folded)
  end

  def display_dot_set(dot_set) do
    max_x =
      dot_set
      |> Enum.map(fn {x, _y} -> x end)
      |> Enum.max()

    max_y =
      dot_set
      |> Enum.map(fn {_x, y} -> y end)
      |> Enum.max()

    Enum.each(
      0..max_y,
      fn y ->
        Enum.each(
          0..max_x,
          fn x ->
            IO.write(if MapSet.member?(dot_set, {x, y}) do "#" else "." end)
          end
        )
        IO.puts("")
      end
    )
  end
end

# atoms
_ = :x
_ = :y

[dots, instructions] =
  File.read!("inputs/day13.txt")
  |> String.trim_trailing()
  |> String.split("\n\n")

# put dots into set
dot_set =
  dots
  |> String.trim_trailing()
  |> String.split("\n")
  |> Enum.map(&Day13.parse_coords/1)
  |> Enum.into(MapSet.new())

# parse instructions
fold_lines =
  instructions
  |> String.trim_trailing()
  |> String.split("\n")
  |> Enum.map(&Day13.parse_instruction/1)

IO.puts(~s(Part 1 answer: #{Day13.part1(dot_set, fold_lines)}))
Day13.part2(dot_set, fold_lines)
