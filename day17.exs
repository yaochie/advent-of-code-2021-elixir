defmodule Day17 do
  def part1(ymin) do
    div(abs(ymin) * abs(ymin + 1), 2)
  end

  def part2(xmax, xmin, ymax, ymin) do
    # we can do y and x separately
    xvel_min = find_xvel_min(xmin)
    xvel_max = xmax
    yvel_min = ymin
    yvel_max = abs(ymin + 1)

    # brute force
    velocities =
      for xvel <- xvel_min..xvel_max, yvel <- yvel_min..yvel_max, do: {xvel, yvel}

    velocities
    |> Enum.filter(fn {xvel, yvel} -> simulate(xmax, xmin, ymax, ymin, xvel, yvel, 0, 0) end)
    |> length()
  end

  defp find_xvel_min(xmin) do
    root = (xmin * 2) ** 0.5
    candidates = [floor(root), ceil(root)]
    Enum.find(candidates, fn x -> div(x * (x + 1), 2) >= xmin end)
  end

  defp simulate(xmax, xmin, ymax, ymin, xvel, yvel, xpos, ypos) do
    cond do
      xmin <= xpos and xpos <= xmax and ymin <= ypos and ypos <= ymax ->
        true
      xpos > xmax ->
        false
      ypos < ymin ->
        false
      true ->
        simulate(xmax, xmin, ymax, ymin, max(0, xvel - 1), yvel - 1, xpos + xvel, ypos + yvel)
    end
  end
end

input =
  "inputs/day17.txt"
  |> File.read!()
  |> String.trim_trailing()

captures = Regex.named_captures(~r/target area: x=(?<xmin>-?[[:digit:]]+)\.\.(?<xmax>-?[[:digit:]]+), y=(?<ymin>-?[[:digit:]]+)\.\.(?<ymax>-?[[:digit:]]+)/, input)

xmax = String.to_integer(Map.fetch!(captures, "xmax"))
xmin = String.to_integer(Map.fetch!(captures, "xmin"))
ymax = String.to_integer(Map.fetch!(captures, "ymax"))
ymin = String.to_integer(Map.fetch!(captures, "ymin"))

IO.puts(~s(Part 1 answer: #{Day17.part1(ymin)}))
IO.puts(~s(Part 2 answer: #{Day17.part2(xmax, xmin, ymax, ymin)}))
