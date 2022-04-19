defmodule ChatFCoinTest.Helper.UserMessageHttpSenderTest do
  use ExUnit.Case, async: true
  doctest ChatFCoin

  alias ChatFCoin.Helper.HttpSender

  test "MockTest" do
    Mox.stub_with(ChatFCoin.Helper.HttpSenderTestMock, ChatFCoin.Helper.HttpSenderMock)

  end
end
