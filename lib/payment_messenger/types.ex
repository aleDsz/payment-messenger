defmodule PaymentMessenger.Types do
  @moduledoc """
  The custom type wrapper for ISO-8583 message
  """

  @doc """
  Injects `regex` module attribute to handle call to `cast/1` function
  """
  defmacro __using__(_) do
    caller = __CALLER__.module

    Module.register_attribute(caller, :regex, accumulate: false, persist: true)
    Module.put_attribute(caller, :regex, ~r/(.*)/i)

    quote do
      use Ecto.Type
      @before_compile PaymentMessenger.Types

      def type, do: :tuple
    end
  end

  @doc """
  Injects Ecto.Type missing functions from contract to validate
  with the `PaymentMessenger.Types.Validator` custom validator
  """
  defmacro __before_compile__(_) do
    quote do
      alias PaymentMessenger.Types.Validator

      def regex, do: @regex

      def cast(value) do
        Validator.cast(value, @regex)
      end

      defdelegate load(value), to: Validator
      defdelegate dump(value), to: Validator
    end
  end
end
