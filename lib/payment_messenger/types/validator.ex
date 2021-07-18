defmodule PaymentMessenger.Types.Validator do
  @moduledoc """
  The custom Ecto types validator for ISO-8583
  """

  # Guard to check if given value is a valid tag
  defguardp is_tag(tag) when byte_size(tag) == 3 or byte_size(tag) == 7

  @typep value :: String.t() | integer()
  @typep tlv :: {String.t(), pos_integer() | Range.t(), value()}
  @typep success :: {:ok, tlv()}
  @typep error :: {:error, keyword(String.t())}
  @typep result :: success() | error()

  @doc """
  Cast TLV tuple into given data
  """
  @spec cast(tlv(), Regex.t()) :: result()
  def cast({tag, tag_length, value}, regex) when is_tag(tag) do
    validate_value(value, regex, tag_length)
  end

  def cast(tuple, _) when is_tuple(tuple) do
    {:error, [message: "invalid tuple format"]}
  end

  def cast(_, _) do
    {:error, [message: "isn't tuple"]}
  end

  @doc """
  Load TLV tuple into valid TLV tuple
  """
  @spec load(tlv()) :: result()
  def load({tag, tag_length, value}) when is_tag(tag) do
    {:ok, {tag, length_to_string(value, tag_length), value}}
  end

  def load(tuple) when is_tuple(tuple) do
    {:error, [message: "invalid tuple format"]}
  end

  def load(_) do
    {:error, [message: "isn't tuple"]}
  end

  @doc """
  Dump TLV tuple into valid TLV tuple
  """
  @spec dump(tlv()) :: result()
  def dump({tag, tag_length, value}) when is_tag(tag) do
    {:ok, {tag, length_to_string(value, tag_length), value}}
  end

  def dump(tuple) when is_tuple(tuple) do
    {:error, [message: "invalid tuple format"]}
  end

  def dump(_) do
    {:error, [message: "isn't tuple"]}
  end

  defp validate_value(value, regex, tag_length) do
    string_value = to_string(value)

    with {:match, true} <- {:match, String.match?(string_value, regex)},
         {:length, true} <- {:length, valid_length?(string_value, tag_length)} do
      {:ok, value}
    else
      {:match, false} ->
        {:error, [message: "invalid format"]}

      {:length, false} ->
        {:error, [message: "invalid size"]}
    end
  end

  defp valid_length?(value, tag_length = _start_size.._end_size) do
    String.length(value) in tag_length
  end

  defp valid_length?(value, tag_length) when is_integer(tag_length) do
    String.length(value) == tag_length
  end

  defp valid_length?(_, _), do: false

  defp length_to_string(_value, tag_length) when is_integer(tag_length) do
    tag_length
    |> to_string()
    |> String.pad_leading(3, "0")
  end

  defp length_to_string(value, _start_size.._end_size) do
    value
    |> String.length()
    |> to_string()
    |> String.pad_leading(3, "0")
  end
end
