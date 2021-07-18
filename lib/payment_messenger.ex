defmodule PaymentMessenger do
  @moduledoc """
  Documentation for `PaymentMessenger`.
  """

  @doc """
  Gets the config entry for `PaymentMessenger` app
  """
  @spec get_config(atom(), any()) :: any()
  def get_config(key, default \\ nil) do
    Application.get_env(:payment_messenger, key, default)
  end
end
