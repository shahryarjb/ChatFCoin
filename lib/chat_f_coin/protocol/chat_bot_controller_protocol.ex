defprotocol ChatFCoin.ChatBotControllerProtocol do
  @spec webhook(struct()) :: Plug.Conn.t()
  def webhook(args)
end


defimpl ChatFCoin.ChatBotControllerProtocol, for: ChatFCoin.Plugin.FacebookSubscribe.FacebookSubscribeBehaviour do
  alias ChatFCoin.Plugin.FacebookSubscribe.FacebookSubscribeBehaviour
  alias ChatFCoin.Plugin.FacebookUserMessage.FacebookUserMessageBehaviour
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
  alias ChatFCoin.UserMsgDynamicGenserver
  import Plug.Conn

  @spec webhook(FacebookUserMessageBehaviour.t()) :: Plug.Conn.t()
  def webhook(%FacebookUserMessageBehaviour{message_id: message_id, message: message, sender_id: sender_id, object: "page", conn: conn})
    when not is_nil(sender_id) and not is_nil(message_id) and not is_nil(message) do
    # TODO: send a new message to user and ask them or say something
    state =
      %FacebookUserMessageBehaviour{message_id: message_id, message: message, sender_id: sender_id, object: "page", conn: conn}

    %UserMsgDynamicGenserver{user_id: sender_id, user_answers: [UserMsgDynamicGenserver.user_message(message["quick_reply"]["payload"])], parent_pid: self(), social_network: "facebook"}
    |> UserMsgDynamicGenserver.push_call()
    |> case do
      {:error, :push, _result} ->
        %FacebookUserMessageBehaviour{conn: conn, object: "nopage"}
        |> ChatFCoin.ChatBotControllerProtocol.webhook()

      _pushed_value ->
        MishkaInstaller.Hook.call(event: "on_facebook_user_message", state: state).conn
        |> send_resp(200, "EVENT_RECEIVED")
    end
  end

  def webhook(%FacebookUserMessageBehaviour{conn: conn} = _params), do: send_resp(conn, 404, "NOT_FOUND")
end
