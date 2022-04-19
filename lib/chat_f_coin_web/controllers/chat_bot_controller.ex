defmodule ChatFCoinWeb.ChatBotController do
  use ChatFCoinWeb, :controller
  alias ChatFCoin.Plugin.{
    FacebookUserMessage.FacebookUserMessageBehaviour,
    FacebookSubscribe.FacebookSubscribeBehaviour
  }
  alias ChatFCoin.ChatBotControllerProtocol
  @moduledoc """
    When you want to create a Facebook Chatbot, you should consider two connections are sent to you as the `Webhook` router
    for example, the first one is subscribing and is called when you want to introduce your webhook in the Facebook application
    and the second one is the user message

    ### Introducing callback endpoint to Facebook messenger application
    ```elixir
    %{
      "hub.challenge" => "...",
      "hub.mode" => "subscribe",
      "hub.verify_token" => "..."
    }
    ```

    ### User messages callback endpoint from Facebook messenger, or chat box
    ```
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
    ```

    > it should be noted that Facebook accepts these bodies from our controllers
    * In Introducing callback, we can use these bodies: `"hub.challenge"` -- 200 parameter when the request is successful and if this is not you should use `Unauthorized` -- 403
    * In User messages callback, we can pass these bodies: `EVENT_RECEIVED` -- 200 and `NOT_FOUND` -- 400

    #### Please consider, when you want to send an auto message to specific user you can find the sender id from `User messages callback` action function

    ---

    > In this simple project we can not consider the requests pressure or Facebook Limits, so I can not use any Queue Manager
  """
  @spec webhook(Plug.Conn.t(), map) :: Plug.Conn.t()
  def webhook(conn, %{"hub.challenge" => challenge, "hub.mode" => mode, "hub.verify_token" => verify_token}) do
    # TODO: It can be changed with dynamic parameters in the future
    %FacebookSubscribeBehaviour{mode: mode, challenge: challenge, verify_token: verify_token, conn: conn}
    |> ChatBotControllerProtocol.webhook()
  end

  def webhook(conn, %{"object" => object, "entry" => entries} = _params) do
    # TODO: It can be changed with dynamic parameters in the future
    # TODO: `get_message` value should be sanitized even Facebook is a safe external service, change it in the future
    get_message = List.first(entries)["messaging"] |> List.first
    %FacebookUserMessageBehaviour{
      message_id: List.first(entries)["id"], message: get_message["message"],
      sender_id: get_message["sender"]["id"], object: object, conn: conn
    }
    |> ChatBotControllerProtocol.webhook()
  end
end
