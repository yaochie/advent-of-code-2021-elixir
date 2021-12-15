defmodule Day14 do
  def parse_rule(line) do
    [pair, insert] =
      line
      |> String.trim_trailing()
      |> String.split(" -> ")

    [first, second] = String.graphemes(pair)

    {{first, second}, insert}
  end

  def pair_ins(_pair_counts, single_counts, _rules, 0) do
    {min, max} =
      single_counts
      |> Map.values()
      |> Enum.min_max()

    max - min
  end

  # Use the pairs to find the new pairs, and also add the new characters
  # to single_counts
  def pair_ins(pair_counts, single_counts, rules, num_iters) do
    {new_pairs, new_singles} =
      Enum.reduce(
        pair_counts,
        {Map.new(), single_counts},
        fn {{first, second} = pair, count}, {pairs, singles} ->
          new_char = Map.fetch!(rules, pair)

          new_pairs =
            pairs
            |> Map.update({first, new_char}, count, &(&1 + count))
            |> Map.update({new_char, second}, count, &(&1 + count))

          new_singles = Map.update(singles, new_char, count, &(&1 + count))

          {new_pairs, new_singles}
        end
      )

    pair_ins(new_pairs, new_singles, rules, num_iters - 1)
  end
end

[template_str, rules_str] =
  File.read!("inputs/day14.txt")
  |> String.trim_trailing()
  |> String.split("\n\n")

template = String.graphemes(template_str)

rules =
  rules_str
  |> String.split("\n")
  |> Enum.map(&Day14.parse_rule/1)
  |> Enum.into(Map.new())

single_counts = Enum.frequencies(template)

pairs = Enum.zip(Enum.drop(template, -1), Enum.drop(template, 1))
pair_counts = Enum.frequencies(pairs)

part1_ans = Day14.pair_ins(pair_counts, single_counts, rules, 10)
IO.puts(~s(Part 1 answer: #{part1_ans}))

part2_ans = Day14.pair_ins(pair_counts, single_counts, rules, 40)
IO.puts(~s(Part 2 answer: #{part2_ans}))
