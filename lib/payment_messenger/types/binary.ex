defmodule PaymentMessenger.Types.Binary do
  @moduledoc """
  A binary type for ISO-8583 allowed types
  """
  use PaymentMessenger.Types
  @regex ~r/\b[01]+\b/
end
