defmodule ChatFCoinTest.Helper.FacebookUserRequestTest do
  use ExUnit.Case, async: true
  doctest ChatFCoin

  setup do
    Mox.stub_with(ChatFCoin.Helper.HttpSenderTestMock, ChatFCoin.Helper.HttpSenderMock)
    :ok
  end

  test "run_message/3 when request-number in [0, 100, 500]" do
    assert ChatFCoin.SocialNetwork.Facebook.run_message("TestUserId", "Shahryar", 0) == {:ok, %{
      text: "Hi Shahryar, Please select one of the bottom way to load list of coins"
    }}

    assert ChatFCoin.SocialNetwork.Facebook.run_message("TestUserId", "Shahryar", 100) == {:ok, %{
      text: "Dear Shahryar, Unfortunately, your answer is not in our list of requirements. Please select only from the options below"
    }}

    assert ChatFCoin.SocialNetwork.Facebook.run_message("TestUserId", "Shahryar", 500) == {:ok, %{
      text: "Unfortunately, we can not access to Coin server!! Please try again or cancel operation and try later."
    }}
  end

  test "run_message/3 when request-number in [1, 2]" do
    msg = "For more information please select a coin"
    assert ChatFCoin.SocialNetwork.Facebook.run_message("TestUserId", "Shahryar", 1) == {:ok, %{text: msg}}
    assert ChatFCoin.SocialNetwork.Facebook.run_message("TestUserId", "Shahryar", 2) == {:ok, %{text: msg}}
  end

  test "run_message/3 when we have coin_id" do
    assert ChatFCoin.SocialNetwork.Facebook.run_message("TestUserId", "Shahryar", 14) == {:ok,
    %{
      text: "This is the 14 Days log \n\n * Time: 2022/4/6 -- Price: 45635.45438126673 \n\n * Time: 2022/4/7 -- Price: 43198.77526936491 \n\n * Time: 2022/4/8 -- Price: 43515.15032279806 \n\n * Time: 2022/4/9 -- Price: 42315.70972421807 \n\n * Time: 2022/4/10 -- Price: 42796.39747810973 \n\n * Time: 2022/4/11 -- Price: 42274.907370256085 \n\n * Time: 2022/4/12 -- Price: 39603.965159284155 \n\n * Time: 2022/4/13 -- Price: 40205.67794073206 \n\n * Time: 2022/4/14 -- Price: 41205.16871904067 \n\n * Time: 2022/4/15 -- Price: 39959.457069033735 \n\n * Time: 2022/4/16 -- Price: 40586.59730938673 \n\n * Time: 2022/4/17 -- Price: 40450.37930543977 \n\n * Time: 2022/4/18 -- Price: 39739.11925622209 \n\n * Time: 2022/4/19 -- Price: 40833.5379650337 \n\n * Time: 2022/4/19 -- Price: 40835.34747114774 \n"
    }}
  end

  test "Get User info from Facebook" do
    %{
      "first_name" => "Shahryar",
      "id" => _profile_id,
      "last_name" => "Tavakkoli",
      "profile_pic" => _profile_image
    } = assert ChatFCoin.SocialNetwork.Facebook.get_user("TestUserId")
  end
end
