defmodule PaymentMessenger.TLV.Base do
  @moduledoc """
  The TLV base module

  It defines callbacks for the module that would
  implement validations and custom field for
  ISO-8583 message pattern.
  """

  @typep tag :: String.t()
  @typep tag_length :: pos_integer() | Range.t()
  @typep value :: String.t()
  @typep tlv :: {tag(), tag_length(), value()}

  @callback get_field!(tag()) :: atom() | no_return()
  @callback get_length!(tag()) :: tag_length() | no_return()
  @callback get_tag!(atom()) :: tag() | no_return()
  @callback encode_to_tuple(tag(), value()) :: {:ok, tlv()} | {:error, String.t()}
end
