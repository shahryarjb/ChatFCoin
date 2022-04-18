defmodule ChatFCoinTest.Helper.UserMessageHttpSenderTest do
  use ExUnit.Case, async: true
  doctest ChatFCoin

  alias ChatFCoin.Helper.HttpSender
  # This tests are like Mocks for extrenal api with a timeout
  # Normally I do not prefer to do this, but Facebook has been banned in our country and I need to use VPN, so I got different errors
  test "Sender no User id" do
    {:ok, _error} = assert HttpSender.run_message("user_id", "Shahryar", 0)
  end

  test "Get user info when you have no accses token as local, and there is no information for the user" do
    %{"first_name" => "Dear client", "last_name" => "", "profile_pic" => "", "id" => ""} = assert HttpSender.get_user_info("person_id", "no_token")
  end

  test "Message sender without token" do
    body = HttpSender.message_body(:shor, "no_user", "Hi Dear")
    {:ok, _error} = assert HttpSender.send_message(body, "no_token")
  end

  test "Message body" do
    body1 = HttpSender.message_body(:shor, "no_user", "Hi Dear")
    assert body1 == %{message: %{text: "Hi Dear"}, recipient: %{id: "no_user"}}

    buttons = [{"Get Coins with Name", "CoinWithName"}, {"Get Coins with Id", "CoinWithId"}, {"Cancel Operation", "Cancel"}]
    body2 = HttpSender.message_body(:temporary_button, "no_user", buttons, "Hi Dear")
    %{
      message: %{
        quick_replies: _btn,
        text: "Hi Dear"
      },
      messaging_type: "RESPONSE",
      recipient: %{id: "no_user"}
    } = assert body2
  end
end
