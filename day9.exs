defmodule Day9 do
  def part1(height_map, num_rows, num_cols) do
    height_map
    |> Enum.filter(&(is_low?(height_map, num_rows, num_cols, &1)))
    |> Enum.map(fn {_pos, height} -> height + 1 end)
    |> Enum.sum()
  end

  defp is_low?(height_map, num_rows, num_cols, {{r, c}, height}) do
    neighbours = [{r-1, c}, {r+1, c}, {r, c-1}, {r, c+1}]

    num_neighbours(num_rows, num_cols, neighbours) ==
      num_higher_neighbours(height_map, neighbours, height)
  end

  defp num_neighbours(num_rows, num_cols, neighbours) do
    # count the number of neighbours that actually exist
    neighbours
    |> Enum.filter(&(in_bounds?(num_rows, num_cols, &1)))
    |> length()
  end

  defp num_higher_neighbours(height_map, neighbours, height) do
    higher? =
      fn pos -> Map.get(height_map, pos, -1) > height end

    neighbours
    |> Enum.filter(higher?)
    |> length()
  end

  def part2(height_map, num_rows, num_cols) do
    low_points =
      Enum.filter(
        height_map,
        &(is_low?(height_map, num_rows, num_cols, &1))
      )

    basin_sizes = Enum.map(low_points, &(basin_size(height_map, num_rows, num_cols, &1)))

    basin_sizes
    |> Enum.sort(&(&1 >= &2))
    |> Enum.take(3)
    |> Enum.reduce(fn x, acc -> x * acc end)
  end

  defp basin_size(height_map, num_rows, num_cols, low_point) do
    # find basins using bfs
    MapSet.size(bfs(height_map, num_rows, num_cols, [low_point], MapSet.new()))
  end

  defp bfs(_, _, _, [], basin) do
    basin
  end

  defp bfs(height_map, num_rows, num_cols, frontier, basin) do
    update_fn =
      fn point, acc ->
        higher_neighbours = get_higher_neighbours(height_map, num_rows, num_cols, point)
        acc ++ higher_neighbours
      end

    new_frontier = Enum.reduce(frontier, [], update_fn)

    bfs(height_map, num_rows, num_cols, new_frontier, Enum.into(frontier, basin))
  end

  defp get_higher_neighbours(height_map, num_rows, num_cols, {{r, c}, height}) do
    [{r-1, c}, {r+1, c}, {r, c-1}, {r, c+1}]
    |> Enum.filter(&(in_bounds?(num_rows, num_cols, &1)))
    |> Enum.filter(&(Map.fetch!(height_map, &1) > height))
    |> Enum.map(&({&1, Map.fetch!(height_map, &1)}))
    |> Enum.filter(fn {_pos, height} -> height != 9 end)
  end

  defp in_bounds?(num_rows, num_cols, {r, c}) do
    r >= 0 and r < num_rows and c >= 0 and c < num_cols
  end
end

lines =
  File.read!("inputs/day9.txt")
  |> String.trim_trailing()
  |> String.split("\n")

num_rows = length(lines)

num_cols =
  lines
  |> hd()
  |> byte_size()

# build map of (r, c) -> height
heights =
  lines
  |> Enum.join()
  |> String.graphemes()
  |> Enum.map(&String.to_integer/1)

update_height =
  fn {height, idx}, acc ->
    r = div(idx, num_cols)
    c = rem(idx, num_cols)
    Map.put(acc, {r, c}, height)
  end

height_map =
  heights
  |> Enum.with_index()
  |> Enum.reduce(Map.new(), update_height)

IO.puts(~s(Part 1 answer: #{Day9.part1(height_map, num_rows, num_cols)}))
IO.puts(~s(Part 2 answer: #{Day9.part2(height_map, num_rows, num_cols)}))
