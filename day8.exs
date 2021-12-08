defmodule Day8 do
  def parse_entry(line) do
    [patterns, output] = String.split(line, " | ")
    %{patterns: String.split(patterns, " "), output: String.split(output, " ")}
  end

  def part1(entries) do
    entries
    |> Stream.map(&count_uniques/1)
    |> Enum.sum()
  end

  defp count_uniques(%{patterns: _patterns, output: output}) do
    # count only digits that have a unique number of wires
    output
    |> Enum.filter(fn s -> s |> byte_size() |> is_unique?() end)
    |> length()
  end

  defp is_unique?(num_wires) do
    num_wires == 2 or num_wires == 3 or num_wires == 4 or num_wires == 7
  end

  def part2(entries) do
    entries
    |> Stream.map(&get_value/1)
    |> Enum.sum()
  end

  defp get_value(%{patterns: patterns, output: output}) do
    connections = get_connections(patterns)
    resolve_output(connections, output)
  end

  defp pattern_to_segments(pattern) do
    # convert the strings to sets of letters
    pattern
    |> :binary.bin_to_list()
    |> MapSet.new()
  end

  defp get_connections(patterns) do
    # get mapping from set of letters to digit.
    # 1,4,7,8 -> number of segments
    # 9 -> compare all 6segments with 4 by number of overlapping segments
    # 2 -> compare all 5segments with 9
    # 3,5 -> compare remaining 5segments with 1
    # 0,6 -> compare remaining 6segments with 1

    digit_sets = Enum.map(patterns, &pattern_to_segments/1)

    # digits that have unique number of segments
    uniques = %{
      2 => 1,
      3 => 7,
      4 => 4,
      7 => 8,
    }

    # find the unique ones first
    add_unique =
      fn set, {mapping, rev_mapping} ->
        case Map.get(uniques, MapSet.size(set)) do
          nil -> {mapping, rev_mapping}
          n -> {Map.put(mapping, set, n), Map.put(rev_mapping, n, set)}
        end
      end
    {mapping, rev_mapping} = Enum.reduce(digit_sets, {%{}, %{}}, add_unique)

    # 0 and 4 -> 3
    # 6 and 4 -> 3
    # 9 and 4 -> 4
    set4 = Map.fetch!(rev_mapping, 4)
    set9 = Enum.find(
      digit_sets,
      fn set ->
        MapSet.size(set) == 6 and MapSet.size(MapSet.intersection(set, set4)) == 4
      end
    )
    mapping = Map.put(mapping, set9, 9)

    # 3 and 9 -> 5
    # 2 and 9 -> 4
    # 5 and 9 -> 5
    set2 = Enum.find(
      digit_sets,
      fn set ->
        MapSet.size(set) == 5 and MapSet.size(MapSet.intersection(set, set9)) == 4
      end
    )
    mapping = Map.put(mapping, set2, 2)

    # 3 and 1 -> 2
    # 5 and 1 -> 1
    set1 = Map.fetch!(rev_mapping, 1)
    compare_five_segments_with_1 =
      fn set, mapping ->
        cond do
          MapSet.size(set) != 5 or Map.has_key?(mapping, set) ->
            mapping
          MapSet.size(MapSet.intersection(set, set1)) == 2 ->
            # found 3
            Map.put(mapping, set, 3)
          MapSet.size(MapSet.intersection(set, set1)) == 1 ->
            # found 5
            Map.put(mapping, set, 5)
        end
      end
    mapping = Enum.reduce(digit_sets, mapping, compare_five_segments_with_1)

    # 0 and 1 -> 2
    # 6 and 1 -> 1
    compare_six_segments_with_1 =
      fn set, mapping ->
        cond do
          MapSet.size(set) != 6 or Map.has_key?(mapping, set) ->
            mapping
          MapSet.size(MapSet.intersection(set, set1)) == 2 ->
            # found 0
            Map.put(mapping, set, 0)
          MapSet.size(MapSet.intersection(set, set1)) == 1 ->
            # found 6
            Map.put(mapping, set, 6)
        end
      end
    Enum.reduce(digit_sets, mapping, compare_six_segments_with_1)
  end

  defp resolve_output(connections, output) do
    output
    |> Enum.map(&pattern_to_segments/1)
    |> Enum.map(fn segments -> Map.fetch!(connections, segments) end)
    |> Enum.join()
    |> String.to_integer()
  end
end

entries =
  File.read!("inputs/day8.txt")
  |> String.trim_trailing()
  |> String.split("\n")
  |> Enum.map(&Day8.parse_entry/1)

IO.puts(~s(Part 1: #{Day8.part1(entries)}))
IO.puts(~s(Part 2: #{Day8.part2(entries)}))
