# :value is the literaL value or the sub-packets
defmodule Packet do
  @enforce_keys [:type, :version, :bit_length, :value]
  defstruct [:type, :version, :bit_length, :value]
end

defmodule Day16 do
  # returns {packet, rest}
  def parse_packet(data) do
    # parse header
    << version::3, type_id::3, rest::bitstring >> = data

    # IO.puts(~s(version: #{version}))
    # IO.puts(~s(type ID: #{type_id}))

    if type_id == 4 do
      # literal
      {literal, bit_length, rest} = parse_literal(rest)
      {%Packet{type: type_id, version: version, bit_length: bit_length, value: literal}, rest}
    else
      # operator
      {sub_packets, bit_length, rest} = parse_operator(rest)
      {%Packet{type: type_id, version: version, bit_length: bit_length + 6, value: sub_packets}, rest}
    end
  end

  def parse_literal(data) do
    do_parse_literal(data, "", 6)
  end

  defp do_parse_literal(<< flag::1, value::4, rest::bitstring >>, acc, bit_length) do
    new_value = << acc::bitstring, value::4 >>
    new_bit_length = bit_length + 5

    if flag == 0 do
      literal_bits = bit_size(new_value)
      << literal::integer-size(literal_bits) >> = new_value

      {literal, new_bit_length, rest}
    else
      do_parse_literal(rest, new_value, new_bit_length)
    end
  end

  def parse_operator(<< 0::1, bit_length::15, rest::bitstring >>) do
    # IO.puts(~s(parsing type 0 operator with bit length #{bit_length}))
    do_parse_type0_operator(rest, [], bit_length)
  end

  def parse_operator(<< 1::1, num_sub_packets::11, rest::bitstring >>) do
    # IO.puts(~s(parsing type 1 operator with #{num_sub_packets} sub-packets))
    do_parse_type1_operator(rest, [], num_sub_packets)
  end

  defp do_parse_type0_operator(data, sub_packets, 0) do
    packet_bits =
      sub_packets
      |> Enum.map(fn %Packet{bit_length: bit_length} -> bit_length end)
      |> Enum.sum()

    {Enum.reverse(sub_packets), packet_bits + 16, data}
  end

  defp do_parse_type0_operator(data, sub_packets, bit_length) do
    {packet, rest} = parse_packet(data)
    %Packet{bit_length: packet_bits} = packet
    remaining_bit_length = bit_length - packet_bits
    do_parse_type0_operator(rest, [packet | sub_packets], remaining_bit_length)
  end

  defp do_parse_type1_operator(data, sub_packets, 0) do
    packet_bits =
      sub_packets
      |> Enum.map(fn %Packet{bit_length: bit_length} -> bit_length end)
      |> Enum.sum()

    {Enum.reverse(sub_packets), packet_bits + 12, data}
  end

  defp do_parse_type1_operator(data, sub_packets, num_sub_packets) do
    {packet, rest} = parse_packet(data)
    do_parse_type1_operator(rest, [packet | sub_packets], num_sub_packets - 1)
  end

  # literal
  def part1(%Packet{type: 4, version: version}) do
    version
  end

  def part1(%Packet{version: version, value: sub_packets}) do
    sub_packet_sum =
      sub_packets
      |> Enum.map(&part1/1)
      |> Enum.sum()

    sub_packet_sum + version
  end
end

_ = :literal
_ = :operator

data =
  File.read!("inputs/day16.txt")
  |> String.trim_trailing()
  |> Base.decode16!()

IO.inspect(data)

{packet, _padding} = Day16.parse_packet(data)

# part 1: sum of version numbers
IO.puts(~s(Part 1 answer: #{Day16.part1(packet)}))
