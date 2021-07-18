defmodule PaymentMessenger.Message do
  @moduledoc """
  The ISO-8583 message schema.

  It implements the `PaymentMessenger.Message` behaviour and
  module attributes like `request_fields`, `response_fields` and
  `shared_fields`, which helps when developing functions that could
  return the message fields.
  """

  @schema_error_message {:error, "Couldn't fetch schema from message"}

  @doc """
  Gets the required and shared fields from `request` type
  """
  @callback request_fields() :: list(atom())

  @doc """
  Gets the required and shared fields from `response` type
  """
  @callback response_fields() :: list(atom())

  @doc """
  Gets the shared fields from `request` and `response` type
  """
  @callback shared_fields() :: list(atom())

  @doc """
  Validates the `request` type message from given attributes and return
  the changeset
  """
  @callback request_changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()

  @doc """
  Validates the `response` type message from given attributes and return
  the changeset
  """
  @callback response_changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()

  @doc """
  Injects imports, alias and uses to help the ISO-8583 message development.

  It also implements `request_fields`, `response_fields` and `shared_fields`
  module attributes.
  """
  defmacro __using__(_) do
    caller = __CALLER__.module

    Module.register_attribute(caller, :request_fields, accumulate: false, persist: true)
    Module.register_attribute(caller, :response_fields, accumulate: false, persist: true)
    Module.register_attribute(caller, :shared_fields, accumulate: false, persist: true)

    Module.put_attribute(caller, :request_fields, [])
    Module.put_attribute(caller, :response_fields, [])
    Module.put_attribute(caller, :shared_fields, [])

    quote do
      use Ecto.Schema
      import Ecto.Changeset

      @primary_key false
      @behaviour PaymentMessenger.Message
      @before_compile PaymentMessenger.Message
    end
  end

  @doc """
  Injects `request_fields/0`, `response_fields/0` and `shared_fields/0` functions
  to get data from their module attributes (same name as function name)
  """
  defmacro __before_compile__(_) do
    quote do
      @doc false
      def request_fields do
        @request_fields ++ @shared_fields
      end

      @doc false
      def response_fields do
        @response_fields ++ @shared_fields
      end

      @doc false
      def shared_fields do
        @shared_fields
      end
    end
  end

  @doc """
  Get the schema module from given raw message.

  It uses the config entry `:schemas` from application config to handle
  how to search the available schema.

  ## Configuration

  Directly from `config/*.exs`

  ```elixir
  config :payment_messenger,
    schemas: [
      {"0420", "123456", MyApp.MyMessage}
    ]
  ```

  Handle from application function, using arity 2 `my_function(resource, resource_id)`

  ```elixir
  config :payment_messenger, schemas: &MyApp.handle_schemas/2
  ```

  ## Examples

      iex> Application.put_env(:payment_messenger, :schemas, [{"0420", "123456", MyApp.MyMessage}])
      iex> PaymentMessenger.Message.get_schema_from_message("0420123456")
      {:ok, MyApp.MyMessage}

      iex> PaymentMessenger.Message.get_schema_from_message("0000123456")
      {:error, "Couldn't fetch schema from message"}
  """
  @spec get_schema_from_message(<<_::64, _::_*8>>) :: {:ok, module()} | {:error, String.t()}
  def get_schema_from_message(<<resource::binary-size(4), resource_id::binary-size(6)>> <> _) do
    case PaymentMessenger.get_config(:schemas) do
      schemas = [_ | _] -> validate_schemas_list(schemas, resource, resource_id)
      fun when is_function(fun, 2) -> validate_schema_function(fun, resource, resource_id)
      _ -> @schema_error_message
    end
  end

  defp validate_schemas_list(schemas = [_ | _], resource, resource_id) do
    Enum.reduce_while(schemas, @schema_error_message, fn
      {^resource, ^resource_id, schema}, _ ->
        {:halt, {:ok, schema}}

      _, acc ->
        {:cont, acc}
    end)
  end

  defp validate_schema_function(fun, resource, resource_id) do
    case fun.(resource, resource_id) do
      result = {:ok, _} ->
        result

      error = {:error, _} ->
        error
    end
  rescue
    _ ->
      @schema_error_message
  end
end
