defmodule PaymentMessenger.Types.Alphanumeric do
  @moduledoc """
  An alphanumeric type for ISO-8583 allowed types
  """
  use PaymentMessenger.Types
  @regex ~r/^[a-zA-Z0-9_ ]*$/i
end
