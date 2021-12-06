defmodule Day4 do
  def parse_board(board_string) do
    values =
      board_string
      |> String.split()
      |> Enum.map(&String.to_integer/1)

    board =
      values
      |> Enum.with_index()
      |> Map.new(fn {key, idx} -> {key, {div(idx, 5), rem(idx, 5)}} end)

    board
  end

  def part1(numbers, boards) do
    # keep track of marked numbers
    current_status = Enum.map(
      boards,
      fn board -> %{board: board, marked: MapSet.new()} end
    )

    part1_rec(numbers, current_status)
  end

  defp part1_rec([next_number | rest], current_status) do
    case update_boards_rec(next_number, current_status) do
      {:not_done, new_status} ->
        part1_rec(rest, new_status)
      {:done, score} ->
        IO.puts(~s(Part 1 score: #{score}))
    end
  end

  defp update_boards_rec(_number, []) do
    {:not_done, []}
  end

  defp update_boards_rec(number, [board | rest]) do
    case update_board(number, board) do
      {:done, _new_board, score} ->
        {:done, score}
      {:not_done, new_board} ->
        case update_boards_rec(number, rest) do
          {:done, score} ->
            {:done, score}
          {:not_done, new_rest} ->
            {:not_done, [new_board | new_rest]}
        end
    end
  end

  defp update_board(number, current_board) do
    %{board: board, marked: marked} = current_board

    if Map.has_key?(board, number) do
      # add to marked, check if row/col/diag is all marked
      {row, col} = Map.get(board, number)
      new_marked = MapSet.put(marked, {row, col})
      new_board = %{board: board, marked: new_marked}

      if check_done(new_marked, row, col) do
        {:done, new_board, board_score(board, new_marked, number)}
      else
        {:not_done, new_board}
      end
    else
      {:not_done, current_board}
    end
  end

  defp check_done(marked, row, col) do
    # check row
    row_done = Enum.all?(0..4, fn c -> MapSet.member?(marked, {row, c}) end)
    # check col
    col_done = Enum.all?(0..4, fn r -> MapSet.member?(marked, {r, col}) end)

    row_done or col_done
  end

  defp board_score(board, marked, last_number) do
    unmarked_sum =
      board
      |> Enum.map(fn {key, {row, col}} -> if MapSet.member?(marked, {row, col}) do 0 else key end end)
      |> Enum.sum()

    unmarked_sum * last_number
  end

  def part2(numbers, boards) do
    # approach:
    # - Mark all numbers
    # - When a board is completed, add the score to a map
    # - When scores for all boards have been added, the most recent score is
    #   the answer
    current_status =
      boards
      |> Enum.with_index()
      |> Enum.map(fn {board, idx} -> {idx, %{board: board, marked: MapSet.new()}} end)

    part2_rec(numbers, current_status, Map.new())
  end

  defp part2_rec([], _, _) do
    IO.puts("finished!")
  end

  defp part2_rec([next_number | rest], current_status, scores) do
    num_boards = length(current_status)

    update_fn =
      fn {idx, board}, {boards, current_scores} ->
        case update_board(next_number, board) do
          {:done, new_board, board_score} ->
            new_scores = Map.put_new(current_scores, idx, board_score)
            new_acc = {[{idx, new_board} | boards], new_scores}
            if map_size(new_scores) == num_boards do
              IO.puts(~s(Part 2 score: #{board_score}))
              {:halt, new_acc}
            else
              {:cont, new_acc}
            end
          {:not_done, new_board} ->
            {:cont, {[{idx, new_board} | boards], current_scores}}
        end
      end

    {new_status, scores} = Enum.reduce_while(
      current_status,
      {[], scores},
      update_fn
    )

    part2_rec(rest, new_status, scores)
  end
end

parts =
  File.read!("inputs/day4.txt")
  |> String.trim_trailing()
  |> String.split("\n\n")

numbers =
  hd(parts)
  |> String.split(",")
  |> Enum.map(&String.to_integer/1)

boards =
  parts
  |> tl()
  |> Enum.map(&Day4.parse_board/1)

Day4.part1(numbers, boards)
Day4.part2(numbers, boards)
