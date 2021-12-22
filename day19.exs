defmodule Day19 do
  @rotation_matrices [
    [
      [1,0,0],
      [0,1,0],
      [0,0,1]
    ],
    [
      [1,0,0],
      [0,-1,0],
      [0,0,-1]
    ],
    [
      [-1,0,0],
      [0,-1,0],
      [0,0,1]
    ],
    [
      [-1,0,0],
      [0,1,0],
      [0,0,-1]
    ],
    #
    [
      [1,0,0],
      [0,0,-1],
      [0,1,0]
    ],
    [
      [1,0,0],
      [0,0,1],
      [0,-1,0]
    ],
    [
      [-1,0,0],
      [0,0,-1],
      [0,-1,0]
    ],
    [
      [-1,0,0],
      [0,0,1],
      [0,1,0]
    ],
    #
    [
      [0,0,1],
      [0,1,0],
      [-1,0,0]
    ],
    [
      [0,0,-1],
      [0,1,0],
      [1,0,0]
    ],
    [
      [0,0,-1],
      [0,-1,0],
      [-1,0,0]
    ],
    [
      [0,0,1],
      [0,-1,0],
      [1,0,0]
    ],
    #
    [
      [0,-1,0],
      [1,0,0],
      [0,0,1]
    ],
    [
      [0,1,0],
      [-1,0,0],
      [0,0,1]
    ],
    [
      [0,1,0],
      [1,0,0],
      [0,0,-1],
    ],
    [
      [0,-1,0],
      [-1,0,0],
      [0,0,-1]
    ],
    #
    [
      [0,1,0],
      [0,0,-1],
      [-1,0,0]
    ],
    [
      [0,-1,0],
      [0,0,1],
      [-1,0,0]
    ],
    [
      [0,-1,0],
      [0,0,-1],
      [1,0,0]
    ],
    [
      [0,1,0],
      [0,0,1],
      [1,0,0]
    ],
    #
    [
      [0,0,1],
      [1,0,0],
      [0,1,0],
    ],
    [
      [0,0,-1],
      [1,0,0],
      [0,-1,0],
    ],
    [
      [0,0,-1],
      [-1,0,0],
      [0,1,0]
    ],
    [
      [0,0,1],
      [-1,0,0],
      [0,-1,0]
    ]
  ]

  def parse_scanner_data(data) do
    data
    |> String.split("\n")
    |> Enum.drop(1)
    |> Enum.map(fn line -> line |> String.split(",") |> Enum.map(&String.to_integer/1) end)
  end

  def analyse(data) do
    transforms = %{0 => {[0,0,0], [[1,0,0],[0,1,0],[0,0,1]]}}
    transforms = get_overlaps(data, [0], transforms)

    IO.inspect(transforms)

    # transform all beacons, get total (part 1 answer)
    transform_all(data, transforms)

    part2(transforms)
  end

  def part2(transforms) do
    offsets = Map.map(transforms, fn {_idx, {offset, _matrix}} -> offset end)

    pairs = for o1 <- offsets, o2 <- offsets, into: [], do: {o1, o2}

    max_manhattan =
      pairs
      |> Enum.reject(fn {{i1, _}, {i2, _}} -> i1 == i2 end)
      |> Enum.map(fn {{_, o1}, {_, o2}} -> manhattan(o1, o2) end)
      |> Enum.max()

    IO.puts(~s(Part 2 answer: #{max_manhattan}))
  end

  def transform_all(data, transforms) do
    unique_beacons =
      0..29
      |> Enum.flat_map(fn idx ->
        beacons = Map.fetch!(data, idx)
        transform = Map.fetch!(transforms, idx)
        # apply transform
        Enum.map(beacons, fn pos -> apply_transform(pos, transform) end)
      end)
      |> MapSet.new()

    IO.puts(~s(Part 1 answer: #{MapSet.size(unique_beacons)}))
  end

  def apply_transform(pos, {offset, matrix}) do
    pos
    |> multiply(matrix)
    |> add(offset)
  end

  def get_overlaps(data, [idx | new_keys], transforms) do
    scanner = Map.fetch!(data, idx)
    tr = Map.fetch!(transforms, idx)

    overlaps =
      1..29
      |> Enum.reject(&(Map.has_key?(transforms, &1) or &1 == idx))
      |> Enum.map(fn idx -> {idx, get_transform(scanner, Map.fetch!(data, idx))} end)
      |> Enum.reject(fn {_idx, transform} -> is_nil(transform) end)

    overlaps =
      overlaps
      |> Enum.map(fn {idx, transform} -> {idx, recover_transform(tr, transform)} end)
      |> Map.new()

    transforms = Map.merge(transforms, overlaps)

    get_overlaps(data, new_keys ++ Map.keys(overlaps), transforms)
  end

  def get_overlaps(_data, [], transforms) do
    transforms
  end

  def recover_transform({offset1, matrix1}, {offset2, matrix2}) do
    # transform the offset vector to the original coordinate space
    offset2 = multiply(offset2, matrix1)
    # add the offset of the reference point
    offset2 = add(offset1, offset2)
    # get the overall transform
    matrix2 = matmul(matrix2, matrix1)
    {offset2, matrix2}
  end

  def get_transform(set1, set2) do
    # Apply each transform matrix
    # If they overlap, exactly one transform matrix will work
    transforms =
      @rotation_matrices
      |> Enum.map(fn matrix -> check_transform(set1, set2, matrix) end)
      |> Enum.reject(&is_nil/1)

    case transforms do
      [] -> nil
      [transform] -> transform
      _ -> raise "Got more than one transform!"
    end
  end

  def check_transform(set1, set2, matrix) do
    # transform set2
    transformed = Enum.map(set2, fn vector -> multiply(vector, matrix) end)

    # all pairs
    pairs = for a <- set1, b <- transformed, into: [], do: {a, b}

    counts =
      Enum.reduce(pairs, %{}, fn {a, b}, counts ->
        offset = subtract(a, b)
        Map.update(counts, offset, 1, &(&1 + 1))
      end)

    {offset, max_count} = Enum.max_by(counts, fn {_offset, count} -> count end)

    if max_count >= 12 do
      {offset, matrix}
    else
      nil
    end
  end

  # Matrix/vector ops

  def subtract([x1, y1, z1], [x2, y2, z2]) do
    [x1 - x2, y1 - y2, z1 - z2]
  end

  def add([x1, y1, z1], [x2, y2, z2]) do
    [x1 + x2, y1 + y2, z1 + z2]
  end

  def transpose(matrix) do
    matrix
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  # multiply a 3d vector and a 3x3 transform matrix (transposed)
  def multiply(vector, matrix) do
    matrix
    |> transpose()
    |> Enum.map(fn row ->
      Enum.zip(vector, row)
      |> Enum.map(fn {a, b} -> a * b end)
      |> Enum.sum()
    end)
  end

  def dot([x1, y1, z1], [x2, y2, z2]) do
    x1*x2 + y1*y2 + z1*z2
  end

  def matmul(matrix1, matrix2) do
    # transpose matrix 2
    matrix2_t = transpose(matrix2)

    values = for a <- matrix1, b <- matrix2_t, into: [], do: dot(a, b)

    Enum.chunk_every(values, 3, 3, :discard)
  end

  def manhattan([x1, y1, z1], [x2, y2, z2]) do
    abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)
  end
end

data =
  File.read!("inputs/day19.txt")
  |> String.trim_trailing()
  |> String.split("\n\n")
  |> Enum.map(&Day19.parse_scanner_data/1)
  |> Enum.with_index(fn element, index -> {index, element} end)
  |> Enum.into(Map.new())

Day19.analyse(data)
