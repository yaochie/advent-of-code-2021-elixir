defmodule Day5 do
  def parse_line(string) do
    [end1, end2] =
      string
      |> String.split(" -> ")
      |> Enum.map(fn x -> parse_coords(x) end)

    {end1, end2}
  end

  defp parse_coords(string) do
    [x, y] =
      string
      |> String.split(",")
      |> Enum.map(fn x -> String.to_integer(x) end)

    {x, y}
  end

  def part1(lines) do
    # keep only horizontal or vertical
    lines = Enum.reject(lines, fn line -> is_diagonal?(line) end)

    update_fn =
      fn line, board ->
        cond do
          is_horizontal?(line) ->
            update_horizontal(line, board)
          is_vertical?(line) ->
            update_vertical(line, board)
          true ->
            board
        end
      end

    board = Enum.reduce(lines, Map.new(), update_fn)

    # values >= 2
    count =
      board
      |> Map.values()
      |> Enum.count(fn count -> count >= 2 end)

    IO.puts(count)
  end

  defp is_diagonal?({{x1, y1}, {x2, y2}}) do
    (x1 != x2) and (y1 != y2)
  end

  defp is_horizontal?({{_x1, y1}, {_x2, y2}}) do
    y1 == y2
  end

  defp is_vertical?({{x1, _y1}, {x2, _y2}}) do
    x1 == x2
  end

  defp update_horizontal({{x1, y}, {x2, _y}}, board) do
    update_fn =
      fn x, board ->
        Map.update(board, {x, y}, 1, &(&1 + 1))
      end

    Enum.reduce(x1..x2, board, update_fn)
  end

  defp update_vertical({{x, y1}, {_x, y2}}, board) do
    update_fn =
      fn y, board ->
        Map.update(board, {x, y}, 1, &(&1 + 1))
      end

    Enum.reduce(y1..y2, board, update_fn)
  end

  def part2(lines) do
    update_fn =
      fn line, board ->
        cond do
          is_horizontal?(line) ->
            update_horizontal(line, board)
          is_vertical?(line) ->
            update_vertical(line, board)
          true ->
            update_diagonal(line, board)
        end
      end

    board = Enum.reduce(lines, Map.new(), update_fn)

    # values >= 2
    count =
      board
      |> Map.values()
      |> Enum.count(fn count -> count >= 2 end)

    IO.puts(count)
  end

  def update_diagonal({{x1, y1}, {x2, y2}}, board) do
    update_fn =
      fn {x, y}, board ->
        Map.update(board, {x, y}, 1, &(&1 + 1))
      end

    Enum.reduce(Enum.zip(x1..x2, y1..y2), board, update_fn)
  end
end

lines =
  File.read!("inputs/day5.txt")
  |> String.trim_trailing()
  |> String.split("\n")
  |> Enum.map(fn line -> Day5.parse_line(line) end)

Day5.part1(lines)
Day5.part2(lines)
