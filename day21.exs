defmodule Day21 do
  def part1(p1, p2) do
    answer = do_simulate(p1, p2, 0, 0, 1, 0)
    IO.puts(~s(Part 1 answer: #{answer}))
  end

  defp do_simulate(pos, other_pos, score, other_score, die, num_rolls) do
    {move, die} = get_die_sum(die)
    pos = make_move(pos, move)
    score = score + pos
    num_rolls = num_rolls + 3

    if score >= 1000 do
      other_score * num_rolls
    else
      do_simulate(other_pos, pos, other_score, score, die, num_rolls)
    end
  end

  # get the move and new die value for a deterministic 100-sided die
  defp get_die_sum(die) do
    sum = die
    die = rem(die, 100) + 1
    sum = sum + die
    die = rem(die, 100) + 1
    sum = sum + die
    die = rem(die, 100) + 1
    {sum, die}
  end

  # number of possible three-dice rolls for each total
  @move_counts %{
    3 => 1,
    4 => 3,
    5 => 6,
    6 => 7,
    7 => 6,
    8 => 3,
    9 => 1,
  }

  def part2(p1, p2) do
    answer = dirac_simulate(%{{p1, 0} => 1}, %{{p2, 0} => 1}, 0, 0)
    IO.puts(~s(Part 2 answer: #{answer}))
  end

  defp dirac_simulate(states, other_states, score, other_score) do
    IO.inspect({score, other_score})
    states = update_states(states)

    {ended, states} =
      Enum.split_with(states, fn {{_pos, score}, _count} -> score >= 21 end)

    num_ended_states = total_states(ended)
    num_other_states = total_states(other_states)

    score = score + num_ended_states * num_other_states

    if length(states) == 0 do
      IO.puts("done!")
      IO.inspect({score, other_score})
      max(score, other_score)
    else
      dirac_simulate(other_states, states, other_score, score)
    end
  end

  defp total_states(states) do
    Enum.reduce(states, 0, fn {_state, count}, acc -> acc + count end)
  end

  # get all possible next states after a single move (three dirac die)
  def update_states(states) do
    # for each state, get all possible next states and their counts
    states
    |> Enum.flat_map(fn {state, count} ->
      state
      |> make_dirac_move()
      |> Enum.map(fn {next_state, count2} -> {next_state, count * count2} end)
    end)
    # merge the counts together
    |> Enum.reduce(Map.new(), fn {state, count}, acc ->
      Map.update(acc, state, count, &(&1 + count))
    end)
  end

  defp make_dirac_move({pos, score}) do
    Enum.map(@move_counts, fn {move, count} ->
      new_pos = make_move(pos, move)
      new_score = score + new_pos
      {{new_pos, new_score}, count}
    end)
  end

  defp make_move(pos, move) do
    rem(pos + move - 1, 10) + 1
  end
end

# read starting positions from command line args
if length(System.argv()) != 2 do
  raise "Expects two arguments."
end

[p1, p2] = Enum.map(System.argv(), &String.to_integer/1)
IO.puts(~s(P1 starting position: #{p1}))
IO.puts(~s(P2 starting position: #{p2}))

Day21.part1(p1, p2)
IO.puts("")

Day21.part2(p1, p2)
