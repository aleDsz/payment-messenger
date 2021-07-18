defmodule PaymentMessenger.Types.Numeric do
  @moduledoc """
  A numeric type for ISO-8583 allowed types
  """
  use PaymentMessenger.Types
  @regex ~r/[0-9]+/i
end
