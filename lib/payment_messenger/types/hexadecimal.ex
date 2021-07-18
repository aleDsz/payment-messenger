defmodule PaymentMessenger.Types.Hexadecimal do
  @moduledoc """
  A hexadecimal type for ISO-8583 allowed types
  """
  use PaymentMessenger.Types
  @regex ~r/[0-9a-f]+/i
end
