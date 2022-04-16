defmodule ChatFCoinWeb.ChatBotController do
  use ChatFCoinWeb, :controller
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

  # TODO: create a protocol for this router with behaviors and struct for each step
  # TODO: Create some activities function to log
  @spec webhook(Plug.Conn.t(), map) :: Plug.Conn.t()
  def webhook(conn, %{ "hub.challenge" => challenge, "hub.mode" => mode, "hub.verify_token" => verify_token}) do
    with {:verify_token, true} <- {:verify_token, ChatFCoin.get_config(:facebook_chat_accsess_token) == verify_token},
         {:hub_mod, true} <- {:hub_mod, mode == "subscribe"} do

      # TODO: Add an event to make the code modular
      conn
      |> send_resp(200, challenge)
    else
      {:verify_token, false} ->
        # TODO: Add an event to make the code modular
        conn
        |> send_resp(403, "Unauthorized")
      {:hub_mod, false} ->
        # TODO: Add an event to make the code modular
        conn
        |> send_resp(403, "Unauthorized")
    end
  end

  def webhook(conn, %{"object" => _object, "entry" => _entries}) do
    # TODO: send a new message to user and ask them or say something
    # TODO: Add an event to make the code modular
    # TODO: check is there a problem in user's answer or not
    # TODO: check the page parameter is page or not
    # TODO: if user sends something for first time, save him/her in database
    # TODO: check how to send a message after a time, not immediately
    send_resp(conn, 200, "EVENT_RECEIVED")
    # send_resp(conn, 404, "NOT_FOUND")
  end
end
