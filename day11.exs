defmodule Day11 do
  def part1(energy_map) do
    {map, num_flashed} = simulate(energy_map, 100, 0)
    print_map(map)
    num_flashed
  end

  defp simulate(energy_map, 0, num_flashes) do
    {energy_map, num_flashes}
  end

  defp simulate(energy_map, steps, num_flashes) do
    # add 1 to all
    new_map = Map.map(energy_map, fn {_key, val} -> val + 1 end)

    # flash all greater than 9
    {new_map, num_flashed} = flash(new_map)

    simulate(new_map, steps - 1, num_flashes + num_flashed)
  end

  defp flash(energy_map) do
    {flashed_map, flashed} = flash_rec(energy_map, MapSet.new())

    # set flashed to zero
    updated_map =
      Map.map(flashed_map, fn {_key, val} -> if val > 9 do 0 else val end end)

    {updated_map, MapSet.size(flashed)}
  end

  defp flash_rec(energy_map, flashed) do
    to_flash =
      energy_map
      |> Map.filter(fn {_key, val} -> val > 9 end)
      |> Map.keys()
      |> MapSet.new()
      |> MapSet.difference(flashed)

    if MapSet.size(to_flash) == 0 do
      {energy_map, flashed}
    else
      incr_fn =
        fn {r, c}, acc ->
          Enum.reduce(
            [
              {r+1, c+1}, {r+1, c}, {r+1, c-1},
              {r, c+1}, {r, c-1},
              {r-1, c-1}, {r-1, c}, {r-1, c+1}
            ],
            acc,
            fn pos, acc ->
              if Map.has_key?(acc, pos) do
                Map.update!(acc, pos, &(&1 + 1))
              else
                acc
              end
            end
          )
        end

      # increment all adjacent
      flashed_map = Enum.reduce(to_flash, energy_map, incr_fn)

      flash_rec(flashed_map, MapSet.union(to_flash, flashed))
    end
  end

  defp print_map(energy_map) do
    map_str =
      0..99
      |> Enum.map(fn x -> {div(x, 10), rem(x, 10)} end)
      |> Enum.chunk_by(fn {r, _c} -> r end)
      |> Enum.map(fn row -> row |> Enum.map(fn pos -> Map.fetch!(energy_map, pos) end) |> Enum.join() end)
      |> Enum.join("\n")

    IO.puts(map_str)
  end

  def part2(energy_map) do
    find_sync_step(energy_map, 1)
  end

  defp find_sync_step(energy_map, step) do
    # add 1 to all
    new_map = Map.map(energy_map, fn {_key, val} -> val + 1 end)

    # flash all greater than 9
    {new_map, num_flashed} = flash(new_map)

    if num_flashed == 100 do
      step
    else
      find_sync_step(new_map, step + 1)
    end
  end
end

lines =
  File.read!("inputs/day11.txt")
  |> String.trim_trailing()
  |> String.split("\n")

num_cols =
  lines
  |> hd()
  |> byte_size()

# build map of (r, c) -> energy
energies =
  lines
  |> Enum.join()
  |> String.graphemes()
  |> Enum.map(&String.to_integer/1)

update_energy =
  fn {energy, idx}, acc ->
    r = div(idx, num_cols)
    c = rem(idx, num_cols)
    Map.put(acc, {r, c}, energy)
  end

energy_map =
  energies
  |> Enum.with_index()
  |> Enum.reduce(Map.new(), update_energy)

IO.puts(~s(Part 1 answer: #{Day11.part1(energy_map)}))
IO.puts(~s(Part 2 answer: #{Day11.part2(energy_map)}))
