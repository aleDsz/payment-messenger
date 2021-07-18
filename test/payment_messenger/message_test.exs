defmodule PaymentMessenger.MessageTest do
  use ExUnit.Case
  doctest PaymentMessenger.Message

  alias PaymentMessenger.Message

  require TemporaryEnv

  describe "with `TestMessage`" do
    defmodule TestMessage do
      use PaymentMessenger.Message

      @request_fields ~w(icc)a
      @shared_fields ~w(resource_id time date)a
      @response_fields ~w(response_code)a

      schema "test_message" do
        field(:resource_id, :string)
        field(:time, :string)
        field(:date, :string)
        field(:icc, :string)
        field(:response_code, :string)
      end

      @doc false
      def request_changeset(schema = %__MODULE__{}, attrs) do
        schema
        |> cast(attrs, request_fields())
        |> validate_required(@request_fields)
      end

      @doc false
      def response_changeset(schema = %__MODULE__{}, attrs) do
        schema
        |> cast(attrs, response_fields())
        |> validate_required(@response_fields)
      end
    end

    test "returns the request fields" do
      assert ~w(icc resource_id time date)a == TestMessage.request_fields()
    end

    test "returns the response fields" do
      assert ~w(response_code resource_id time date)a == TestMessage.response_fields()
    end

    test "returns the shared fields" do
      assert ~w(resource_id time date)a == TestMessage.shared_fields()
    end
  end

  describe "with `MyApp`" do
    defmodule MyApp do
      def handle_schemas("0420", "123456"), do: {:ok, PaymentMessenger.MessageTest.TestMessage}
      def handle_schemas("0420", _), do: {:error, "Invalid schema"}
    end

    test "return the schema from given raw message" do
      TemporaryEnv.put :payment_messenger, :schemas, &MyApp.handle_schemas/2 do
        assert {:ok, PaymentMessenger.MessageTest.TestMessage} ==
                 Message.get_schema_from_message("0420123456")
      end
    end

    test "return custom error when schema doesn't exist from given raw message" do
      TemporaryEnv.put :payment_messenger, :schemas, &MyApp.handle_schemas/2 do
        assert {:error, "Invalid schema"} == Message.get_schema_from_message("0420123446")
      end
    end

    test "return error when schema doesn't exist from given raw message" do
      TemporaryEnv.put :payment_messenger, :schemas, &MyApp.handle_schemas/2 do
        assert {:error, "Couldn't fetch schema from message"} ==
                 Message.get_schema_from_message("0400123456")
      end
    end
  end
end
