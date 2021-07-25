defmodule PaymentMessenger.Parser.Decoder do
  @moduledoc """
  The TLV message decoder
  """

  @unused_tags ~w(001 002)

  @doc """

  """
  @spec parse(String.t()) ::
          {:ok, PaymentMessenger.Message.t()}
          | {:error, Ecto.Changeset.t()}
          | {:error, any()}
  def parse(message) do
  end
end
