defmodule Chat.ProtocolTest do
  use ExUnit.Case, async: true

  alias Chat.Message.{Broadcast, Register}

  describe "decode_message/1" do
    test "can decode register messages" do
      binary = <<0x01, 0x00, 0x03, "meg", "rest">>
      assert {:ok, message, rest} = Chat.Protocol.decode_message(binary)
      assert message == %Register{username: "meg"}
      assert rest == "rest"
    end

    test "when message is incomplete returns :incomplete" do
      assert Chat.Protocol.decode_message(<<0x01, 0x00>>) == :incomplete
    end

    test "can decode broadcast messages" do
      binary = <<0x02, 3::16, "meg", 2::16, "hi", "rest">>
      assert {:ok, message, rest} = Chat.Protocol.decode_message(binary)
      assert message == %Broadcast{from_username: "meg", contents: "hi"}
      assert rest == "rest"
    end

    test "returns incomplete when message is incomplete" do
      assert Chat.Protocol.decode_message(<<0x02, 0x00>>) == :incomplete
    end

    test "returns :incomplete for empty data" do
      assert Chat.Protocol.decode_message("") == :incomplete
    end

    test "returns :error for unknown message types" do
      assert Chat.Protocol.decode_message(<<0x03, "rest">>) == :error
    end
  end
end
