defmodule PaymentMessenger.Parser.Bitmap do
  @moduledoc """
  The bitmap generator and decoder from TLV messages
  """

  @typep integer_tags :: list(non_neg_integer())
  @typep tags :: list(String.t())
  @typep message :: String.t()
  @typep bitmap :: String.t()
  @typep error :: {:error, String.t()}

  @allowed_sizes [64, 128]
  @secondary_bitmap ~w(8 9 A B C D E F)

  @doc """
  Generates the bitmap from a list of tags

  ## Examples

      iex> PaymentMessenger.Parser.Bitmap([2, 5, 13])
      "000"
  """
  @spec generate(integer_tags()) :: bitmap() | error()
  def generate([]), do: {:error, "invalid bitmap"}

  def generate(tags = [tag | _]) when is_list(tags) and is_integer(tag) do
    bitmap_size = get_bitmap_size(tags)

    bitmap_size
    |> convert_to_bitmap(tags)
    |> put_first_bit(bitmap_size)
    |> convert_to_hexadecimal()
    |> validate_bitmap()
  end

  defp get_bitmap_size(tags = [_ | _]) do
    case List.last(tags) do
      number when number in 65..128 ->
        128

      _ ->
        64
    end
  end

  defp convert_to_bitmap(bitmap_size, tags = [_ | _]) do
    1..bitmap_size
    |> Enum.map(&is_member?(tags, &1))
    |> Enum.chunk_every(4)
    |> Enum.map(&calculate_bitmap/1)
  end

  defp is_member?(bit, tags) do
    if Enum.member?(tags, bit) do
      1
    else
      0
    end
  end

  defp calculate_bitmap([bit8, bit4, bit2, bit1]) do
    bit8 = if bit8 == 0, do: 0, else: 8
    bit4 = if bit4 == 0, do: 0, else: 4
    bit2 = if bit2 == 0, do: 0, else: 2
    bit1 = if bit1 == 0, do: 0, else: 1

    bit8 + bit4 + bit2 + bit1
  end

  defp put_first_bit(bitmap = [bit | tail], bitmap_size) do
    case bitmap_size do
      64 ->
        bitmap

      128 ->
        [bit + 8] ++ tail
    end
  end

  defp convert_to_hexadecimal(bitmap = [_ | _]) do
    hexadecimal_list =
      Enum.map(bitmap, fn
        value when value in 0..9 -> to_string(value)
        10 -> "A"
        11 -> "B"
        12 -> "C"
        13 -> "D"
        14 -> "E"
        15 -> "F"
      end)

    Enum.join(hexadecimal_list, "")
  end

  defp validate_bitmap(<<bitmap::binary-size(16)>>), do: bitmap
  defp validate_bitmap(<<bitmap::binary-size(32)>>), do: bitmap
  defp validate_bitmap(_), do: {:error, "invalid bitmap"}

  @doc """
  Converts the message bitmap to a list of tags

  ## Examples

      iex> PaymentMessenger.Parser.Bitmap.convert_bitmap_to_tags("123456789")
      {[12, 13], ""}
  """
  @spec convert_bitmap_to_tags(message()) :: {tags(), message()} | error()
  def convert_bitmap_to_tags(message) do
    bitmap_size =
      if has_secondary_bitmap?(message) do
        32
      else
        16
      end

    with {bitmap, message} <- get_bitmap(message, bitmap_size),
         bitmap when is_binary(bitmap) <- validate_bitmap(bitmap),
         tags = [_ | _] <- convert_to_tags(bitmap, bitmap_size) do
      {tags, message}
    end
  end

  defp has_secondary_bitmap?(
         <<_size::binary-size(4), _resource::binary-size(4), bitmap_size::binary-size(1)>> <>
           _message
       ) do
    bitmap_size in @secondary_bitmap
  end

  defp get_bitmap(message, bitmap_size) do
    <<_size::binary-size(4), _resource::binary-size(4)>> <> message = message
    message_size = String.length(message)

    bitmap = String.slice(message, 0..(bitmap_size - 1))
    message = String.slice(message, bitmap_size..(message_size - 1))

    {bitmap, message}
  end

  defp convert_to_tags(bitmap, bitmap_size) do
    bitmap
    |> slice_bits(bitmap_size)
    |> calculate_bitmap_positions()
    |> validate_size()
  end

  defp slice_bits(bitmap, bitmap_size) do
    0..(bitmap_size - 1)
    |> Enum.reduce([], fn index, acc ->
      {bit, _} =
        bitmap
        |> String.slice(index..index)
        |> Integer.parse(16)

      "0b" <> binary_bit = inspect(bit, base: :binary)

      [binary_bit | acc]
    end)
    |> Enum.reverse()
  end

  defp calculate_bitmap_positions(list_of_bits) do
    Enum.reduce(list_of_bits, [], fn bit, acc ->
      bits =
        bit
        |> String.pad_leading(4, ["0"])
        |> String.slice(0..3)
        |> String.split(~r/|/)
        |> Enum.filter(&(&1 !== ""))

      acc ++ bits
    end)
  end

  defp validate_size(bits) do
    {size, tags} =
      bits
      |> Enum.map(&String.to_integer/1)
      |> Enum.reduce({0, []}, fn
        1, {index, tags} ->
          {index + 1, tags}

        _, {index, tags} ->
          new_index = index + 1
          [new_index | tags]

          {new_index, tags}
      end)

    if size in @allowed_sizes do
      tags
      |> Enum.map(fn tag ->
        tag
        |> to_string()
        |> String.pad_leading(3, "0")
      end)
      |> Enum.reverse()
    else
      {:error, "invalid bitmap"}
    end
  end
end
