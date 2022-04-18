defmodule ChatFCoinTest.State.UserMessageStateTest do
  use ExUnit.Case, async: true
  doctest ChatFCoin
  alias ChatFCoin.UserMsgDynamicGenserver, as: UserMsg


  setup_all _tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ChatFCoin.Repo)
    on_exit fn ->
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(ChatFCoin.Repo)
    end
    [this_is: "is"]
  end

  test "Create a user in state with Push call", %{this_is: _this_is} do
    assert UserMsg.push_call(%UserMsg{
      user_id: "7270301279678601",
      social_network: "facebook",
      parent_pid: self(),
      user_answers: [1]
      }).user_answers == [1]
  end
end
