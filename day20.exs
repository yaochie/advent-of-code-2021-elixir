defmodule Day20 do
  def map_pixel(pixel) do
    case pixel do
      "#" -> 1
      "." -> 0
    end
  end

  # convert image to map from (r, c) to bit
  def parse_image(rows) do
    rows
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, r} ->
      Enum.with_index(String.graphemes(row), fn pixel, c -> {{r, c}, map_pixel(pixel)} end)
    end)
    |> Map.new()
  end

  def enhance(image, algorithm, outside_value) do
    {rmin, rmax} =
      image
      |> Enum.map(fn {{r, _c}, _value} -> r end)
      |> Enum.min_max()

    {cmin, cmax} =
      image
      |> Enum.map(fn {{_r, c}, _value} -> c end)
      |> Enum.min_max()

    locations = for r <- (rmin-1)..(rmax+1), c <- (cmin-1)..(cmax+1), do: {r, c}

    locations
    |> Enum.map(fn loc -> {loc, enhance_pixel(image, algorithm, outside_value, loc)} end)
    |> Map.new()
  end

  def enhance_pixel(image, algorithm, outside_value, {r, c}) do
    offsets = for a <- -1..1, b <- -1..1, do: {a, b}

    key =
      offsets
      |> Enum.map(fn {a, b} -> Map.get(image, {r+a, c+b}, outside_value) end)
      |> Integer.undigits(2)

    Map.fetch!(algorithm, key)
  end

  def process(image, algorithm) do
    # part 1
    {image, outside_value} = do_enhance(image, algorithm, 0, 2)
    IO.puts(~s(Part 1 answer: #{num_lit(image)}))

    # part 2
    {image, _outside_value} = do_enhance(image, algorithm, outside_value, 48)
    IO.puts(~s(Part 2 answer: #{num_lit(image)}))
  end

  def do_enhance(image, _algorithm, outside_value, 0) do
    {image, outside_value}
  end

  def do_enhance(image, algorithm, outside_value, num_iter) do
    image = enhance(image, algorithm, outside_value)
    key =
      outside_value
      |> Integer.to_string()
      |> String.duplicate(9)
      |> String.to_integer(2)

    outside_value = Map.fetch!(algorithm, key)

    do_enhance(image, algorithm, outside_value, num_iter - 1)
  end

  def num_lit(image) do
    Enum.count(image, fn {_key, value} -> value == 1 end)
  end

  def print_image(image) do
    {rmin, rmax} =
      image
      |> Enum.map(fn {{r, _c}, _value} -> r end)
      |> Enum.min_max()

    {cmin, cmax} =
      image
      |> Enum.map(fn {{_r, c}, _value} -> c end)
      |> Enum.min_max()

    Enum.each(rmin..rmax, fn r ->
      Enum.each(cmin..cmax, fn c ->
        pixel =
          case Map.get(image, {r, c}, 0) do
            1 -> "#"
            0 -> "."
          end
        IO.write(pixel)
      end)
      IO.puts("")
    end)
    IO.puts("---------")
  end
end

[algorithm, image] =
  File.read!("inputs/day20.txt")
  |> String.trim_trailing()
  |> String.split("\n\n")

rows = String.split(image, "\n")

image = Day20.parse_image(rows)

# Day20.print_image(image)

algorithm =
  algorithm
  |> String.graphemes()
  |> Enum.with_index(fn pixel, idx -> {idx, Day20.map_pixel(pixel)} end)
  |> Map.new()

Day20.process(image, algorithm)
