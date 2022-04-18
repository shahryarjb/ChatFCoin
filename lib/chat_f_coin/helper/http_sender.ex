defmodule ChatFCoin.Helper.HttpSender do
  @facebook_url "https://graph.facebook.com/v2.6/me/messages"
  @request_name MyHttpClient

  # If there is another chatbot like telegram, I prefer to change this HTTP sender module as helper not for specific social network
  # Not it is like a hardcode sender and it is not my type in coding
  @spec send_message(any, binary | URI.t()) :: {:error, Exception.t} | {:ok, Finch.Response.t()}
  def send_message(body, access_token \\ ChatFCoin.get_config(:facebook_chat_accsess_token)) do
    headers = [
      {"Content-type", "application/json"},
      {"Accept", "application/json"}
    ]

    Finch.build(:post, @facebook_url <> "?access_token=#{access_token}", headers, body |> Jason.encode!())
    |> Finch.request(@request_name)
  end

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


  def get_last_coins(per_page, user_id, first_name, type) do
    url = "https://api.coingecko.com/api/v3/coins?per_page=#{per_page}"
    Finch.build(:get, url)
    |> Finch.request(@request_name)
    |> handle_coins(user_id, first_name, type)
  end

  def get_coin_history(user_id, coin_id, currency, days, first_name) do
    query = %{"id" => coin_id, "vs_currency" => currency, "days" => days}
    url = "https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?#{query}"
    Finch.build(:get, url)
    |> Finch.request(@request_name)
    |> handle_coin_history(user_id, first_name)
  end

  @spec run_message(String.t(), String.t(), integer()) :: {:error, Exception.t} | {:ok, Finch.Response.t()}
  def run_message(user_id, user_first_name, number) when number in [0, 100, 500] do
    buttons = [{"Get Coins with Name", "CoinWithName"}, {"Get Coins with Id", "CoinWithId"}, {"Cancel Operation", "CancelOperation"}]
    message_body(:temporary_button, user_id, buttons, sender_msg(number, user_first_name))
    |> send_message()
    |> handle_message_status(user_id, number)
  end

  def run_message(user_id, first_name, number) when number in [1, 2] do
    get_last_coins(5, user_id, first_name, if(number == 1, do: "id", else: "name"))
  end

  def run_message(user_id, first_name, 3) do
    ChatFCoin.UserMsgDynamicGenserver.delete(user_id: user_id)
    message_body(:shor, user_id, sender_msg(3, first_name))
    |> send_message()
  end

  def run_message(user_id, first_name, coin_id) do
    # TODO: send him selector to load coin again
    get_coin_history(user_id, coin_id, "usd", 14, first_name)
  end

  defp handle_message_status({:error, exception}, user_id, message_number) do
    # TO load a plugin call hook to let developer create a custom plugin for this section of http sender
    if Mix.env() in [:dev, :prod] do
      state = %ChatFCoin.Plugin.HttpSendMessage.HttpSendMessageBehaviour{message_number: message_number, sender_id: user_id, exception: exception}
      {:error, MishkaInstaller.Hook.call(event: "on_http_send_message", state: state).exception}
    else
      {:error, exception}
    end
  end

  defp handle_message_status(result, _user_id, _message_number), do: result

  @spec message_body(:shor, String.t(), String.t()) :: %{message: %{text: any}, recipient: %{id: any}}
  def message_body(:shor, user_id, message), do: %{recipient: %{id: user_id}, message: %{text: message}}

  @spec message_body(:temporary_button, String.t(), [tuple()], String.t()) :: map()
  def message_body(:temporary_button, user_id, buttons, message) do
    buttons = Enum.map(buttons, fn {title, payload} -> %{content_type: "text", title: title, payload: "#{payload}"} end)
    %{recipient: %{id: user_id}, messaging_type: "RESPONSE", message: %{text:  "#{message}", quick_replies: buttons}}
  end

  defp handle_coins({:error, _error}, user_id, user_first_name, _type) do
    run_message(user_id, user_first_name, 500)
  end

  defp handle_coins({:ok, %Finch.Response{body: body, headers: _headers, status: _status}}, user_id, user_first_name, type) do
    buttons =
      body
      |> Jason.decode!()
      |> Enum.map(& {&1["#{type}"], "CoinID:#{&1["id"]}"})

    number = if(type == "id", do: 1, else: 2)
    message_body(:temporary_button, user_id, buttons ++ [{"Cancel Operation", "CancelOperation"}], sender_msg(number, user_first_name))
    |> send_message()
    |> handle_message_status(user_id, number)
  end

  defp handle_coin_history({:error, _error}, user_id, user_first_name) do
    run_message(user_id, user_first_name, 500)
  end

  defp handle_coin_history({:ok, %Finch.Response{body: body, headers: _headers, status: _status}}, user_id, _user_first_name) do
    data = body |> Jason.decode!()
    msg =
      ["This is the 14 Days log"] ++ Enum.map(data["prices"], fn [time, price] -> "Time: #{time} -- Price: #{price} \n" end)
      |> Enum.join("\n ")
    message_body(:shor, user_id, msg)
  end

  defp sender_msg(message, first_name) do
    # TODO: it should be changed with Gettext
    %{
      0 => "Hi #{first_name}, Please select one of the bottom way to load list of coins",
      1 => "For more information please select a coin",
      2 => "For more information please select a coin",
      3 => "Thank you, your activities are going to be deleted in our state completely very soon.",
      100 => "Dear #{first_name}, Unfortunately, your answer is not in our list of requirements. Please select only from the options below",
      500 => "Unfortunately, we can not access to Coin server!! Please try again or cancel operation and try later.",
    }[message]
  end
end
