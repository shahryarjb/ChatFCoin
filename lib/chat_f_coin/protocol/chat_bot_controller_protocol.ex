defprotocol ChatFCoin.ChatBotControllerProtocol do
  @spec webhook(struct()) :: Plug.Conn.t()
  def webhook(args)
end


defimpl ChatFCoin.ChatBotControllerProtocol, for: ChatFCoin.Plugin.FacebookSubscribe.FacebookSubscribeBehaviour do
  alias ChatFCoin.Plugin.FacebookSubscribe.FacebookSubscribeBehaviour
  import Plug.Conn

  @spec webhook(FacebookSubscribeBehaviour.t()) :: Plug.Conn.t()
  def webhook(%FacebookSubscribeBehaviour{mode: mode, challenge: challenge, verify_token: verify_token, conn: conn}) do
    state =
      %FacebookSubscribeBehaviour{mode: mode, challenge: challenge, verify_token: verify_token, conn: conn}

    with {:verify_token, true} <- {:verify_token, ChatFCoin.get_config(:facebook_chat_accsess_token) == verify_token},
         {:hub_mode, true} <- {:hub_mode, mode == "subscribe"} do

      MishkaInstaller.Hook.call(event: "on_facebook_subscribe", state: state).conn
      |> send_resp(200, challenge)
    else
    {:verify_token, false} ->
      MishkaInstaller.Hook.call(event: "on_facebook_subscribe", state: Map.merge(state, %{error: :verify_token})).conn
      |> send_resp(403, "Unauthorized")

    {:hub_mode, false} ->
      MishkaInstaller.Hook.call(event: "on_facebook_subscribe", state: Map.merge(state, %{error: :hub_mode})).conn
      |> send_resp(403, "Unauthorized")
    end
  end
end

defimpl ChatFCoin.ChatBotControllerProtocol, for: ChatFCoin.Plugin.FacebookUserMessage.FacebookUserMessageBehaviour do
  alias ChatFCoin.Plugin.FacebookUserMessage.FacebookUserMessageBehaviour
  import Plug.Conn

  @spec webhook(FacebookUserMessageBehaviour.t()) :: Plug.Conn.t()
  def webhook(%FacebookUserMessageBehaviour{message_id: _message_id, message: _message, sender_id: _sender_id, object: _object, conn: conn}) do
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
