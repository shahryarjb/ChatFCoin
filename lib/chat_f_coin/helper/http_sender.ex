defmodule ChatFCoin.Helper.HttpSender do
  @url "https://graph.facebook.com/v2.6/me/messages"
  @request_name MyHttpClient

  # If there is another chatbot like telegram, I prefer to change this HTTP sender module as helper not for specific social network
  # Not it is like a hardcode sender and it is not my type in coding
  @spec send_message(any, binary | URI.t()) :: {:error, Exception.t} | {:ok, Finch.Response.t()}
  def send_message(body, url \\ @url) do
    access_token = ChatFCoin.get_config(:facebook_chat_accsess_token)

    headers = [
      {"Content-type", "application/json"},
      {"Accept", "application/json"}
    ]

    Finch.build(:post, url <> "?access_token=#{access_token}", headers, body |> Jason.encode!())
    |> Finch.request(@request_name)
  end

  @spec message_body(:shor, integer(), String.t()) :: %{message: %{text: any}, recipient: %{id: any}}
  def message_body(:shor, psid, message), do: %{recipient: %{id: psid}, message: %{text: message}}

  # Ref: https://developers.facebook.com/docs/graph-api/reference/v2.6/user
  # curl -X GET -G \
  # -d 'access_token=<ACCESS_TOKEN>' \
  # https://graph.facebook.com/v13.0/{person-id}/

  @spec get_user_info(integer(), String.t()) :: {:error, Exception.t} | {:ok, Finch.Response.t()}
  def get_user_info(person_id, access_token \\ ChatFCoin.get_config(:facebook_chat_accsess_token)) do
    url = "https://graph.facebook.com/v13.0/#{person_id}?access_token=#{access_token}"
    Finch.build(:get, url)
    |> Finch.request(@request_name)
    |> handle_user_info
  end

  defp handle_user_info({:ok, %{body: body, headers: _headers, status: 200}}), do: Jason.decode!(body)
  # I should pass nil or error as atom, but the message can be sent with Dear client and make him/her smile With our respect
  # It should be noted you can create some useful condition to make code safer like if you cannot access to API what should be done?
  defp handle_user_info(_), do: %{"first_name" => "Dear client", "last_name" => "", "profile_pic" => "", "id" => ""}

  @spec run_message(integer, String.t(), integer()) :: {:error, Exception.t} | {:ok, Finch.Response.t()}
  def run_message(user_id, user_first_name, 1) do
    message_body(:shor, user_id, "Hi #{user_first_name}, Please select one of the bottom way to load list of coin")
    |> send_message()
    |> handle_message_status(user_id, 1)
  end

  defp handle_message_status({:error, exception}, user_id, message_number) do
    # TO load a plugin call hook to let developer create a custom plugin for this section of http sender
    state = %ChatFCoin.Plugin.HttpSendMessage.HttpSendMessageBehaviour{message_number: message_number, sender_id: user_id, exception: exception}
    MishkaInstaller.Hook.call(event: "on_http_send_message", state: state).exception
  end

  defp handle_message_status(result, _user_id, _message_number), do: result
end
