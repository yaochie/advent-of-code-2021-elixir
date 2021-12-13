defmodule Day12 do
  def parse_edge(line) do
    String.split(line, "-")
  end

  defp add_edge(adj_list, src, dst) do
    Map.update(adj_list, src, [dst], &([dst | &1]))
  end

  def build_adj_list(edges) do
    # map from node to adjacent nodes
    update_fn =
      fn [a, b], acc ->
        acc
        |> add_edge(a, b)
        |> add_edge(b, a)
      end

    Enum.reduce(edges, Map.new(), update_fn)
  end

  def part1(adj_list) do
    dfs(adj_list, MapSet.new(), "start")
  end

  defp dfs(_adj_list, _visited, "end") do
    1
  end

  defp dfs(adj_list, visited, next_node) do
    if MapSet.member?(visited, next_node) do
      0
    else
      new_visited =
        if next_node =~ ~r/[a-z]/ do
          MapSet.put(visited, next_node)
        else
          visited
        end

      Map.fetch!(adj_list, next_node)
      |> Enum.map(fn next -> dfs(adj_list, new_visited, next) end)
      |> Enum.sum()
    end
  end

  def part2(adj_list) do
    dfs_2(adj_list, {MapSet.new(), nil}, "start")
  end

  defp dfs_2(_adj_list, _visited, "end") do
    1
  end

  defp dfs_2(adj_list, {visited, double} = state, next_node) do
    cond do
      next_node =~ ~r/[A-Z]/ ->
        # big cave, we can always visit it
        Map.fetch!(adj_list, next_node)
        |> Enum.map(fn next -> dfs_2(adj_list, state, next) end)
        |> Enum.sum()

      not MapSet.member?(visited, next_node) ->
        # small cave that we have never visited before
        new_visited = MapSet.put(visited, next_node)

        Map.fetch!(adj_list, next_node)
        |> Enum.map(fn next -> dfs_2(adj_list, {new_visited, double}, next) end)
        |> Enum.sum()

      not is_nil(double) ->
        # small cave that we've visited at least once, and we've visited
        # some small cave twice
        0

      next_node in ["start", "end"] ->
        # start or end, but we've already visited it
        0

      true ->
        Map.fetch!(adj_list, next_node)
        |> Enum.map(fn next -> dfs_2(adj_list, {visited, next_node}, next) end)
        |> Enum.sum()
    end
  end
end

lines =
  File.read!("inputs/day12.txt")
  |> String.trim_trailing()
  |> String.split("\n")
  |> Enum.map(&Day12.parse_edge/1)

adj_list = Day12.build_adj_list(lines)

IO.puts(~s(Part 1 answer: #{Day12.part1(adj_list)}))
IO.puts(~s(Part 2 answer: #{Day12.part2(adj_list)}))
