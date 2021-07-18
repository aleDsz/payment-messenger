defmodule PaymentMessenger.Types.Text do
  @moduledoc """
  A text type for ISO-8583 allowed types
  """
  use PaymentMessenger.Types
  @regex ~r/(.*)/i
end
