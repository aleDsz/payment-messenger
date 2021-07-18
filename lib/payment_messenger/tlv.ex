defmodule PaymentMessenger.TLV do
  @moduledoc """
  The TLV module handler.

  TLV as the name says, it's a Tag-Length-Value
  message pattern buit by ISO-8583 to handle
  payment messages.

  It's generally used by payment processors that
  send and receive messages from sockets. They
  use it to build single line string with TLV pattern.
  """

  @behaviour PaymentMessenger.TLV.Base

  @doc """
  Gets the field name from TAG.

  You can also implements custom fields for tags
  `048`, `062` and `063`, with the `PaymentMessenger.TLV.Custom`
  behaviour.

  ## Examples

      iex> PaymentMessenger.TLV.get_field!("002")
      :not_used

      iex> PaymentMessenger.TLV.get_field!("001")
      ** (FunctionClauseError) no function clause matching in PaymentMessenger.TLV.get_field_name/1
  """
  @impl true
  def get_field!(tag) do
    case PaymentMessenger.get_config(:tlv_parser) do
      nil ->
        get_field_name(tag)

      parser ->
        get_from_parser!(parser, &get_field_name/1, :get_field, tag)
    end
  end

  @doc """
  Gets the length from TAG.

  You can also implements custom length for tags
  `048`, `062` and `063`, with the `PaymentMessenger.TLV.Custom`
  behaviour.

  ## Examples

      iex> PaymentMessenger.TLV.get_length!("002")
      1..19

      iex> PaymentMessenger.TLV.get_length!("003")
      6

      iex> PaymentMessenger.TLV.get_length!("048")
      1..999

      iex> PaymentMessenger.TLV.get_length!("055")
      1..999

      iex> PaymentMessenger.TLV.get_length!("062")
      1..999

      iex> PaymentMessenger.TLV.get_length!("063")
      1..999

      iex> PaymentMessenger.TLV.get_length!("001")
      ** (FunctionClauseError) no function clause matching in PaymentMessenger.TLV.get_tag_length/1
  """
  @impl true
  def get_length!(tag) do
    case PaymentMessenger.get_config(:tlv_parser) do
      nil ->
        get_tag_length(tag)

      parser ->
        get_from_parser!(parser, &get_tag_length/1, :get_length, tag)
    end
  end

  @doc """
  Gets the TAG from field name.

  ## Examples

      iex> PaymentMessenger.TLV.get_tag!(:resource_id)
      "003"

      iex> PaymentMessenger.TLV.get_tag!(:invalid_field)
      ** (FunctionClauseError) no function clause matching in PaymentMessenger.TLV.get_tag_from_field/1
  """
  @impl true
  def get_tag!(field) do
    case PaymentMessenger.get_config(:tlv_parser) do
      nil ->
        get_tag_from_field(field)

      parser ->
        get_from_parser!(parser, &get_tag_from_field/1, :get_tag, field)
    end
  end

  @doc """
  Encode the tag with value into a TLV tuple.

  ## Examples

      iex> PaymentMessenger.TLV.encode_to_tuple("003", "123456")
      {:ok, {"003", 6, "123456"}}

      iex> PaymentMessenger.TLV.encode_to_tuple("035", "123456789")
      {:ok, {"035", 1..37, "123456789"}}

      iex> PaymentMessenger.TLV.encode_to_tuple(:resource_id, "123456")
      {:ok, {"003", 6, "123456"}}

      iex> PaymentMessenger.TLV.encode_to_tuple("002", "123456789123456789123")
      {:error, "Invalid length of data on tag 002, expected the length between 1 and 19, but got 21."}

      iex> PaymentMessenger.TLV.encode_to_tuple("003", "12345")
      {:error, "Invalid length of data on tag 003, expected the length 6, but got 5."}

      iex> PaymentMessenger.TLV.encode_to_tuple("001", "12345")
      ** (FunctionClauseError) no function clause matching in PaymentMessenger.TLV.get_tag_length/1

      iex> PaymentMessenger.TLV.encode_to_tuple(:invalid_field, "12345")
      ** (FunctionClauseError) no function clause matching in PaymentMessenger.TLV.get_tag_from_field/1
  """
  @impl true
  def encode_to_tuple(tag, value) when is_binary(tag) and is_binary(value) do
    tag_length = get_length!(tag)

    case validate_tlv_value(tag, tag_length, value) do
      tlv = {_, _, _} ->
        {:ok, tlv}

      error = {:error, _} ->
        error
    end
  end

  def encode_to_tuple(field, value) when is_atom(field) and is_binary(value) do
    tag = get_tag!(field)
    encode_to_tuple(tag, value)
  end

  defp validate_tlv_value(tag, tag_length, value) when is_integer(tag_length) do
    if String.length(value) == tag_length do
      {tag, tag_length, value}
    else
      size = String.length(value)

      {:error,
       "Invalid length of data on tag #{tag}, expected the length #{tag_length}, but got #{size}."}
    end
  end

  defp validate_tlv_value(tag, tag_length = start_length..end_length, value) do
    if String.length(value) in tag_length do
      {tag, tag_length, value}
    else
      size = String.length(value)

      {:error,
       "Invalid length of data on tag #{tag}, expected the length between #{start_length} and #{
         end_length
       }, but got #{size}."}
    end
  end

  # Helper to get result from this module or from custom parser
  defp get_from_parser!(parser, fun, function, arg) do
    fun.(arg)
  rescue
    _ ->
      apply(parser, function, [arg])
  end

  defp get_field_name("002"), do: :not_used
  defp get_field_name("003"), do: :resource_id
  defp get_field_name("004"), do: :amount
  defp get_field_name("007"), do: :synchronized_at
  defp get_field_name("011"), do: :machine_nsu
  defp get_field_name("012"), do: :time
  defp get_field_name("013"), do: :date
  defp get_field_name("014"), do: :expiration_date
  defp get_field_name("015"), do: :inserted_at
  defp get_field_name("022"), do: :input_mode
  defp get_field_name("023"), do: :app_pan_sequence_number
  defp get_field_name("035"), do: :card_tracker2
  defp get_field_name("037"), do: :acquirer_nsu
  defp get_field_name("038"), do: :authorization_code
  defp get_field_name("039"), do: :response_code
  defp get_field_name("041"), do: :machine_code
  defp get_field_name("042"), do: :partner_code
  defp get_field_name("048"), do: :additional_data
  defp get_field_name("049"), do: :currency_code
  defp get_field_name("052"), do: :card_pin
  defp get_field_name("055"), do: :icc
  defp get_field_name("062"), do: :acquirer_aditional_data
  defp get_field_name("063"), do: :acquirer_aditional_data2
  defp get_field_name("067"), do: :installments
  defp get_field_name("070"), do: :manager_code
  defp get_field_name("090"), do: :original_transaction_data

  defp get_tag_length("002"), do: 1..19
  defp get_tag_length("003"), do: 6
  defp get_tag_length("004"), do: 12
  defp get_tag_length("007"), do: 10
  defp get_tag_length("011"), do: 6
  defp get_tag_length("012"), do: 6
  defp get_tag_length("013"), do: 4
  defp get_tag_length("014"), do: 4
  defp get_tag_length("015"), do: 4
  defp get_tag_length("022"), do: 3
  defp get_tag_length("023"), do: 3
  defp get_tag_length("035"), do: 1..37
  defp get_tag_length("037"), do: 12
  defp get_tag_length("038"), do: 6
  defp get_tag_length("039"), do: 2
  defp get_tag_length("041"), do: 8
  defp get_tag_length("042"), do: 15
  defp get_tag_length("048"), do: 1..999
  defp get_tag_length("049"), do: 3
  defp get_tag_length("052"), do: 16
  defp get_tag_length("055"), do: 1..999
  defp get_tag_length("062"), do: 1..999
  defp get_tag_length("063"), do: 1..999
  defp get_tag_length("067"), do: 2
  defp get_tag_length("070"), do: 3
  defp get_tag_length("090"), do: 42

  defp get_tag_from_field(:not_used), do: "002"
  defp get_tag_from_field(:resource_id), do: "003"
  defp get_tag_from_field(:amount), do: "004"
  defp get_tag_from_field(:synchronized_at), do: "007"
  defp get_tag_from_field(:machine_nsu), do: "011"
  defp get_tag_from_field(:time), do: "012"
  defp get_tag_from_field(:date), do: "013"
  defp get_tag_from_field(:expiration_date), do: "014"
  defp get_tag_from_field(:inserted_at), do: "015"
  defp get_tag_from_field(:input_mode), do: "022"
  defp get_tag_from_field(:app_pan_sequence_number), do: "023"
  defp get_tag_from_field(:card_tracker2), do: "035"
  defp get_tag_from_field(:acquirer_nsu), do: "037"
  defp get_tag_from_field(:authorization_code), do: "038"
  defp get_tag_from_field(:response_code), do: "039"
  defp get_tag_from_field(:machine_code), do: "041"
  defp get_tag_from_field(:partner_code), do: "042"
  defp get_tag_from_field(:additional_data), do: "048"
  defp get_tag_from_field(:currency_code), do: "049"
  defp get_tag_from_field(:card_pin), do: "052"
  defp get_tag_from_field(:icc), do: "055"
  defp get_tag_from_field(:acquirer_aditional_data), do: "062"
  defp get_tag_from_field(:acquirer_aditional_data2), do: "063"
  defp get_tag_from_field(:installments), do: "067"
  defp get_tag_from_field(:manager_code), do: "070"
  defp get_tag_from_field(:original_transaction_data), do: "090"
end
