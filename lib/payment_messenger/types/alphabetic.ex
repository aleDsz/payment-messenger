defmodule PaymentMessenger.Types.Alphabetic do
  @moduledoc """
  An alphabetic type for ISO-8583 allowed types
  """
  use PaymentMessenger.Types
  @regex ~r/^[a-zA-Z ]*$/i
end
