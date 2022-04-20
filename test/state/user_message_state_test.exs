defmodule ChatFCoinTest.State.UserMessageStateTest do
  use ExUnit.Case, async: false
  doctest ChatFCoin
  alias ChatFCoin.UserMsgDynamicGenserver
  import Mox

  setup :set_mox_global
  setup :set_mox_from_context

  setup do
    Mox.stub_with(ChatFCoin.Helper.HttpSenderTestMock, ChatFCoin.Helper.HttpSenderMock)
    :ok
  end

  test "Push call a user message" do
    UserMsgDynamicGenserver.delete(user_id: "TestUserId")
    push =
      %UserMsgDynamicGenserver{user_id: "TestUserId", user_answers: [nil], parent_pid: nil, social_network: "facebook"}
      |> UserMsgDynamicGenserver.push_call()

      %ChatFCoin.UserMsgDynamicGenserver{
        last_try: _time,
        parent_pid: nil,
        social_network: "facebook",
        user_answers: [nil],
        user_id: _sent_user_id,
        user_info: %{
          "first_name" => "Shahryar",
          "id" => _profile_id,
          "last_name" => "Tavakkoli",
          "profile_pic" => _profile_image
        }
      } = assert push
  end
end
