defmodule PaymentMessenger.TLV.Custom do
  @moduledoc """
  The custom TLV parser.

  It will implements the base functions from behaviour `PaymentMessenger.TLV.Base`,
  and allow custom parsers to use the same contract.

  Also, you don't need to define the standard messages from `TLV` module.
  """

  @typep tag :: String.t()
  @typep tag_length :: pos_integer() | Range.t()

  @callback get_field(tag()) :: atom()
  @callback get_length(tag()) :: tag_length()
  @callback get_tag(atom()) :: tag()
end
