defmodule PaymentMessenger.TypesTest do
  use ExUnit.Case

  alias PaymentMessenger.Types

  describe "with custom type" do
    defmodule CustomType do
      @moduledoc false
      use Types
      @regex ~r/foo/i
    end

    test "returns the defined regex" do
      assert ~r/foo/i == CustomType.regex()
    end

    test "returns the value when casting custom type" do
      assert {:ok, "foo"} == CustomType.cast({"048", 1..999, "foo"})
    end

    test "returns format error when can't cast custom type" do
      assert {:error, [message: "invalid format"]} == CustomType.cast({"048", 1..999, "bar"})
    end

    test "return size error when can't cast custom type" do
      assert {:error, [message: "invalid size"]} == CustomType.cast({"013", 4, "foo"})
    end

    test "return tuple format error when can't cast custom type" do
      assert {:error, [message: "invalid tuple format"]} ==
               CustomType.cast({"01377123", 4, "foo"})
    end

    test "return general error when can't cast custom type" do
      assert {:error, [message: "isn't tuple"]} == CustomType.cast("foo")
    end

    test "returns the tlv tuple when loading data with custom type" do
      assert {:ok, {"048", "003", "foo"}} == CustomType.load({"048", 1..999, "foo"})
    end

    test "returns the tlv tuple when dumping data with custom type" do
      assert {:ok, {"013", "003", "foo"}} == CustomType.dump({"013", 3, "foo"})
    end
  end
end
