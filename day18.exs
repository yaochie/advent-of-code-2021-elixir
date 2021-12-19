defmodule Day18 do
  def magnitude([left, right]) do
    3 * magnitude(left) + 2 * magnitude(right)
  end

  def magnitude(number) when is_integer(number) do
    number
  end

  # Parse snailfish numbers by treating them as Elixir code.
  def parse_snailfish(line) do
    {snailfish, _bindings} = Code.eval_string(line)
    snailfish
  end

  def add(left, right) do
    reduce([left, right])
  end

  def reduce(snailfish) do
    case do_reduce(snailfish) do
      {:reduced, snailfish} -> reduce(snailfish)
      {:noreduced} -> snailfish
    end
  end

  def do_reduce(snailfish) do
    case explode(snailfish, 0) do
      {:explode, _left, _right, snailfish} ->
        {:reduced, snailfish}
      {:noexplode} ->
        case split(snailfish) do
          {:split, snailfish} ->
            {:reduced, snailfish}
          {:nosplit} ->
            {:noreduced}
        end
    end
  end

  # to explode:
  # - take the left number, and add it to the first number on the left
  # - take the right number, and add it to the first number on the right
  # - replace the pair with 0
  def explode(number, _depth) when is_integer(number) do
    {:noexplode}
  end

  def explode([left, right], 4) do
    {:explode, left, right, 0}
  end

  def explode([left, right], depth) when depth < 4 do
    case explode(left, depth + 1) do
      {:explode, a, b, left} ->
        # right must have a number inside
        right = add_left(right, b)
        {:explode, a, nil, [left, right]}
      {:noexplode} ->
        case explode(right, depth + 1) do
          {:explode, a, b, right} ->
            # left must have a number inside
            left = add_right(left, a)
            {:explode, nil, b, [left, right]}
          {:noexplode} ->
            {:noexplode}
        end
    end
  end

  def add_left(snailfish, nil) do
    snailfish
  end

  def add_left(number, value) when is_integer(number) do
    number + value
  end

  def add_left([left, right], value) do
    [add_left(left, value), right]
  end

  def add_right(snailfish, nil) do
    snailfish
  end

  def add_right(number, value) when is_integer(number) do
    number + value
  end

  def add_right([left, right], value) do
    [left, add_right(right, value)]
  end

  def split(snailfish) when is_integer(snailfish) do
    if snailfish < 10 do
      {:nosplit}
    else
      {:split, [floor(snailfish / 2), ceil(snailfish / 2)]}
    end
  end

  def split([left, right]) do
    case split(left) do
      {:split, left} ->
        {:split, [left, right]}
      {:nosplit} ->
        case split(right) do
          {:split, right} ->
            {:split, [left, right]}
          {:nosplit} ->
            {:nosplit}
        end
    end
  end

  def part1(snailfishes) do
    snailfishes
    |> Enum.reduce(fn next, acc -> add(acc, next) end)
    |> magnitude()
  end

  def part2(snailfishes) do
    # add all possible pairs
    idx_snailfishes = Enum.with_index(snailfishes)

    idx_snailfishes
    |> Enum.map(fn {snailfish, idx} ->
      Enum.map(idx_snailfishes, fn {sn2, idx2} ->
        if idx2 == idx do
          0
        else
          magnitude(add(snailfish, sn2))
        end
      end)
      |> Enum.max()
    end)
    |> Enum.max()
  end
end

snailfishes =
  File.read!("inputs/day18.txt")
  |> String.trim_trailing()
  |> String.split("\n")
  |> Enum.map(&Day18.parse_snailfish/1)

IO.puts(Day18.part1(snailfishes))
IO.puts(Day18.part2(snailfishes))
