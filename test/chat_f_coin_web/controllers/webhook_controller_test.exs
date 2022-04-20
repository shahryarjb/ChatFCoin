defmodule ChatFCoinWeb.WebhookControllerTest do
  use ChatFCoinWeb.ConnCase, async: false

  import Mox

  setup :set_mox_global
  setup :set_mox_from_context

  setup do
    Mox.stub_with(ChatFCoin.Helper.HttpSenderTestMock, ChatFCoin.Helper.HttpSenderMock)
    on_exit(fn -> ChatFCoin.UserMsgDynamicGenserver.delete(user_id: "TestUserId") end)
    :ok
  end

  describe "Happy | ChatFcoin API Webhook Controller (▰˘◡˘▰)" do
    test "Register Webhook into Facebook Apps", %{conn: conn} do
      Application.put_env(:chat_f_coin, ChatFCoinWeb.Endpoint, facebook_chat_accsess_token: "verify_token")
      query = %{"hub.challenge" => "challenge", "hub.mode" => "subscribe", "hub.verify_token" => "verify_token"}
      assert get(conn, Routes.chat_bot_path(conn, :webhook), query).status == 200
    end

    test "Get Facebook Message from Webhook", %{conn: _conn} do
      new_conn = Phoenix.ConnTest.build_conn()
      |> Plug.Conn.put_req_header("content-type", "application/json" )
      assert post(new_conn, Routes.chat_bot_path(new_conn, :webhook), face_book_message()).status == 200
    end
  end

  describe "UnHappy | ChatFcoin API Webhook Controller ಠ╭╮ಠ" do
    test "Register Webhook into Facebook Apps", %{conn: conn} do
      query = %{"hub.challenge" => "challenge", "hub.mode" => "mode", "hub.verify_token" => "verify_token"}
      assert get(conn, Routes.chat_bot_path(conn, :webhook), query).status == 403

      Application.put_env(:chat_f_coin, ChatFCoinWeb.Endpoint, facebook_chat_accsess_token: "verify_token")
      query = %{"hub.challenge" => "challenge", "hub.mode" => "test", "hub.verify_token" => "verify_token"}
      assert get(conn, Routes.chat_bot_path(conn, :webhook), query).status == 403
    end

    test "Get Facebook Message from Webhook", %{conn: _conn} do
      new_conn = Phoenix.ConnTest.build_conn()
      |> Plug.Conn.put_req_header("content-type", "application/json" )
      query = Map.merge(face_book_message(), %{"object" => "nonpage"})
      assert post(new_conn, Routes.chat_bot_path(new_conn, :webhook), query).status == 404
    end

    test "Get Facebook Message from Webhook without essential params", %{conn: _conn} do
      new_conn = Phoenix.ConnTest.build_conn()
      |> Plug.Conn.put_req_header("content-type", "application/json" )
      query = %{"entry" => [%{"id" => "FackID", "time" => 1650123700689}], "object" => "page"}
      assert post(new_conn, Routes.chat_bot_path(new_conn, :webhook), query).status == 404
    end
  end


  defp face_book_message() do
    %{
      "entry" => [
        %{
          "id" => "...",
          "messaging" => [
            %{
              "message" => %{
                "mid" => ".....",
                "text" => "hi"
              },
              "recipient" => %{"id" => "...."},
              "sender" => %{"id" => "...."},
              "timestamp" => 1650123294015
            }
          ],
          "time" => 1650123700689
        }
      ],
      "object" => "page"
    }
  end
end
