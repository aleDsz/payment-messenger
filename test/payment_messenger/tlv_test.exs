defmodule PaymentMessenger.TLVTest do
  use ExUnit.Case
  doctest PaymentMessenger.TLV

  alias PaymentMessenger.TLV

  require TemporaryEnv

  defmodule CustomParser do
    @moduledoc false
    @behaviour TLV.Custom

    def get_field("048-001"), do: :custom_field
    def get_length("048-001"), do: 5
    def get_tag(:custom_field), do: "048-001"
  end

  describe "with `CustomParser` and 048-001 tag" do
    test "returns the custom field name from tag" do
      TemporaryEnv.put :payment_messenger, :tlv_parser, CustomParser do
        assert :custom_field == TLV.get_field!("048-001")
      end
    end

    test "returns the custom field length" do
      TemporaryEnv.put :payment_messenger, :tlv_parser, CustomParser do
        assert 5 == TLV.get_length!("048-001")
      end
    end

    test "returns the tag from custom field name" do
      TemporaryEnv.put :payment_messenger, :tlv_parser, CustomParser do
        assert "048-001" == TLV.get_tag!(:custom_field)
      end
    end

    test "encodes a valid field from custom field tag" do
      TemporaryEnv.put :payment_messenger, :tlv_parser, CustomParser do
        assert {:ok, {"048-001", 5, "12345"}} == TLV.encode_to_tuple("048-001", "12345")
      end
    end

    test "encodes a valid field from custom field name" do
      TemporaryEnv.put :payment_messenger, :tlv_parser, CustomParser do
        assert {:ok, {"048-001", 5, "12345"}} == TLV.encode_to_tuple(:custom_field, "12345")
      end
    end

    test "returns error with an invalid field from custom field name" do
      TemporaryEnv.put :payment_messenger, :tlv_parser, CustomParser do
        message = "Invalid length of data on tag 048-001, expected the length 5, but got 6."

        assert {:error, message} == TLV.encode_to_tuple(:custom_field, "123456")
      end
    end
  end

  describe "with `CustomParser` and 048-002 tag" do
    test "throws an exception when trying to get the field name" do
      TemporaryEnv.put :payment_messenger, :tlv_parser, CustomParser do
        assert_raise FunctionClauseError,
                     "no function clause matching in PaymentMessenger.TLVTest.CustomParser.get_field/1",
                     fn ->
                       TLV.get_field!("048-002")
                     end
      end
    end

    test "throws an exception when trying to get the tag length" do
      TemporaryEnv.put :payment_messenger, :tlv_parser, CustomParser do
        assert_raise FunctionClauseError,
                     "no function clause matching in PaymentMessenger.TLVTest.CustomParser.get_length/1",
                     fn ->
                       TLV.get_length!("048-002")
                     end
      end
    end

    test "throws an exception when trying to get the tag name" do
      TemporaryEnv.put :payment_messenger, :tlv_parser, CustomParser do
        assert_raise FunctionClauseError,
                     "no function clause matching in PaymentMessenger.TLVTest.CustomParser.get_tag/1",
                     fn ->
                       TLV.get_tag!(:another_field)
                     end
      end
    end

    test "throws an exception when trying to get the encode to tuple using tag" do
      TemporaryEnv.put :payment_messenger, :tlv_parser, CustomParser do
        assert_raise FunctionClauseError,
                     "no function clause matching in PaymentMessenger.TLVTest.CustomParser.get_length/1",
                     fn ->
                       TLV.encode_to_tuple("048-002", "123456")
                     end
      end
    end

    test "throws an exception when trying to get the encode to tuple using field name" do
      TemporaryEnv.put :payment_messenger, :tlv_parser, CustomParser do
        assert_raise FunctionClauseError,
                     "no function clause matching in PaymentMessenger.TLVTest.CustomParser.get_tag/1",
                     fn ->
                       TLV.encode_to_tuple(:another_field, "123456")
                     end
      end
    end
  end
end
