defmodule PQ do
  def create(), do: :gb_sets.empty()

  def singleton(value), do: :gb_sets.singleton(value)

  def insert(queue, value), do: :gb_sets.add(value, queue)

  def peek(queue), do: :gb_sets.smallest(queue)

  def pop(queue), do: :gb_sets.take_smallest(queue)

  def is_empty(queue), do: :gb_sets.is_empty(queue)
end

defmodule Day15 do
  def part1(cave) do
    height =
      cave
      |> Enum.map(fn {{r, _}, _} -> r end)
      |> Enum.max()

    width =
      cave
      |> Enum.map(fn {{_, c}, _} -> c end)
      |> Enum.max()

    # Day15.djikstra({cave, height, width}, Map.new(), [{{0, 0}, 0}], {height, width})
    Day15.fast_djikstra(
      {cave, height, width},
      Map.new(),
      PQ.singleton({0, {0, 0}}), {height, width}
    )
  end

  def djikstra(_cave, visited, [], dst) do
    Map.fetch!(visited, dst)
  end

  # slow djikstra's as we don't have a priority queue
  def djikstra({cave, height, width} = cave_map, visited, to_visit, dst) do
    {{r, c} = loc, risk} = Enum.min_by(to_visit, fn {_loc, risk} -> risk end)

    # IO.inspect({loc, risk})

    new_visited = Map.put_new(visited, loc, risk)
    new_to_visit = Enum.reject(to_visit, fn {l, _risk} -> l == loc end)

    # add all neighbours that haven't been visited
    neighbours =
      [{r-1, c}, {r+1, c}, {r, c-1}, {r, c+1}]
      |> Enum.reject(
        fn {r, c} = loc ->
          r < 0 or r > height or c < 0 or c > width or Map.has_key?(visited, loc)
        end
      )
      |> Enum.map(fn loc -> {loc, risk + Map.fetch!(cave, loc)} end)

    new_to_visit = neighbours ++ new_to_visit

    djikstra(cave_map, new_visited, new_to_visit, dst)
  end

  def fast_djikstra({cave, height, width} = cave_map, visited, to_visit, dst) do
    if PQ.is_empty(to_visit) do
      Map.fetch!(visited, dst)
    else
      {{risk, {r, c} = loc}, new_to_visit} = PQ.pop(to_visit)

      if Map.has_key?(visited, loc) do
        fast_djikstra(cave_map, visited, new_to_visit, dst)
      else
        new_visited = Map.put_new(visited, loc, risk)

        # add all neighbours that haven't been visited
        neighbours =
          [{r-1, c}, {r+1, c}, {r, c-1}, {r, c+1}]
          |> Enum.reject(
            fn {r, c} = loc ->
              r < 0 or r > height or c < 0 or c > width or Map.has_key?(visited, loc)
            end
          )
          |> Enum.map(fn loc -> {loc, risk + Map.fetch!(cave, loc)} end)

        updated_to_visit =
          Enum.reduce(
            neighbours,
            new_to_visit,
            fn {loc, risk}, acc -> PQ.insert(acc, {risk, loc}) end
          )

        fast_djikstra(cave_map, new_visited, updated_to_visit, dst)
      end
    end
  end

  def part2(cave) do
    # dumb way: actually put the new cave tiles in.
    new_cave = extend_cave(cave)

    height =
      new_cave
      |> Enum.map(fn {{r, _}, _} -> r end)
      |> Enum.max()

    width =
      new_cave
      |> Enum.map(fn {{_, c}, _} -> c end)
      |> Enum.max()

    # fast_djikstra drops runtime from 10 to 1 second
    # Day15.djikstra({new_cave, height, width}, Map.new(), [{{0, 0}, 0}], {height, width})
    Day15.fast_djikstra(
      {new_cave, height, width},
      Map.new(),
      PQ.singleton({0, {0, 0}}), {height, width}
    )
  end

  defp extend_cave(cave) do
    height =
      (
        cave
        |> Enum.map(fn {{r, _}, _} -> r end)
        |> Enum.max()
      ) + 1

    width =
      (
        cave
        |> Enum.map(fn {{_, c}, _} -> c end)
        |> Enum.max()
      ) + 1

    coords = 0..24
    |> Enum.map(fn i -> {div(i, 5), rem(i, 5)} end)

    coords
    |> Enum.map(
      fn {x, y} ->
        Enum.map(
          cave,
          fn {{r, c}, risk} ->
            {{r + x * height, c + y * width}, rem(risk - 1 + x + y, 9) + 1}
          end
        )
        |> Enum.into(Map.new())
      end
    )
    |> Enum.reduce(Map.new(), fn map, acc -> Map.merge(acc, map) end)
  end

  defp print_cave(cave) do
    height =
      cave
      |> Enum.map(fn {{r, _}, _} -> r end)
      |> Enum.max()

    width =
      cave
      |> Enum.map(fn {{_, c}, _} -> c end)
      |> Enum.max()

    IO.inspect({height, width})

    0..height
    |> Enum.each(
      fn r ->
        Enum.each(0..width, fn c -> IO.write(Map.fetch!(cave, {r, c})) end)
        IO.puts("")
      end
    )
  end
end

# map from (row, col) to risk
cave =
  File.read!("inputs/day15.txt")
  |> String.trim_trailing()
  |> String.split("\n")
  |> Enum.map(
    fn row ->
      row
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
    end
  )
  |> Enum.with_index()
  |> Enum.reduce(
    Map.new(),
    fn {row, r}, acc ->
      Enum.reduce(row, acc, fn {risk, c}, acc -> Map.put(acc, {r, c}, risk) end)
    end
  )

IO.puts(~s(Part 1 answer: #{Day15.part1(cave)}))
IO.puts(~s(Part 2 answer: #{Day15.part2(cave)}))
