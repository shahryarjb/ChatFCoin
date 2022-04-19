defmodule ChatFCoin.SocialNetwork.Facebook do

  @spec run_message(String.t(), String.t(), integer()) :: {:error, Exception.t} | {:ok, Finch.Response.t()}
  def run_message(user_id, user_first_name, number) when number in [0, 100, 500] do
    buttons = [{"Get Coins with Name", "CoinWithName"}, {"Get Coins with Id", "CoinWithId"}, {"Cancel Operation", "CancelOperation"}]
    message_body(:temporary_button, user_id, buttons, sender_msg(number, user_first_name))
    |> ChatFCoin.http_client().http_send_message()
    |> handle_message_status(user_id, number)
  end

  def run_message(user_id, first_name, number) when number in [1, 2] do
    get_coins(5, user_id, first_name, if(number == 2, do: "id", else: "name"))
  end

  def run_message(user_id, first_name, 3) do
    ChatFCoin.UserMsgDynamicGenserver.delete(user_id: user_id)
    message_body(:shor, user_id, sender_msg(3, first_name))
    |> ChatFCoin.http_client().http_send_message()
  end

  def run_message(user_id, first_name, coin_id) do
    # TODO: send him selector to load coin again
    get_coin_history(user_id, coin_id, "usd", 14, first_name)
  end

  defp handle_message_status({:error, exception}, user_id, message_number) do
    # TO load a plugin call hook to let developer create a custom plugin for this section of http sender
    if Mix.env() in [:dev, :prod] do
      state = %ChatFCoin.Plugin.HttpSendMessage.HttpSendMessageBehaviour{message_number: message_number, sender_id: user_id, exception: exception}
      {:error, MishkaInstaller.Hook.call(event: "on_http_http_send_message", state: state).exception}
    else
      {:error, exception}
    end
  end

  defp handle_message_status(result, _user_id, _message_number), do: result

  @spec message_body(:shor, String.t(), String.t()) :: %{message: %{text: any}, recipient: %{id: any}}
  defp message_body(:shor, user_id, message), do: %{recipient: %{id: user_id}, message: %{text: message}}

  @spec message_body(:temporary_button, String.t(), [tuple()], String.t()) :: map()
  defp message_body(:temporary_button, user_id, buttons, message) do
    buttons = Enum.map(buttons, fn {title, payload} -> %{content_type: "text", title: title, payload: "#{payload}"} end)
    %{recipient: %{id: user_id}, messaging_type: "RESPONSE", message: %{text:  "#{message}", quick_replies: buttons}}
  end

  defp get_coins(per_page, user_id, first_name, type) do
    case ChatFCoin.http_client().http_get_coins(per_page) do
      {:ok, %Finch.Response{body: body, headers: _headers, status: _status}} ->
        buttons =
          body
          |> Jason.decode!()
          |> Enum.map(& {&1["#{type}"], "CoinID:#{&1["id"]}"})

        number = if(type == "id", do: 2, else: 1)
        message_body(:temporary_button, user_id, buttons ++ [{"Cancel Operation", "CancelOperation"}], sender_msg(number, first_name))
        |> ChatFCoin.http_client().http_send_message()
        |> handle_message_status(user_id, number)

      {:error, _error} ->
        run_message(user_id, first_name, 500)
    end
  end

  defp get_coin_history(user_id, coin_id, currency, days, first_name) do
    case ChatFCoin.http_client().http_get_coin_history(coin_id, currency, days) do
      {:ok, %Finch.Response{body: body, headers: _headers, status: _status}} ->

        Task.Supervisor.start_child(__MODULE__, fn ->
          :timer.sleep(3000)
          # We can get previous request from the user state to know what type the user prefers for loading last 5 coins again,
          # but for now it is not nessery
          run_message(user_id, first_name, 1)
        end)

        data = body |> Jason.decode!()
        msg =
          ["This is the 14 Days log \n"] ++ Enum.map(data["prices"], fn [time, price] -> "* Time: #{convert_unix_to_string(time)} -- Price: #{price} \n" end)
          |> Enum.join("\n ")
        message_body(:shor, user_id, msg)
        |> ChatFCoin.http_client().http_send_message()

      {:error, _error} ->
        run_message(user_id, first_name, 500)
    end
  end

  defp convert_unix_to_string(timestamp) do
    time =
      timestamp
      |> DateTime.from_unix!(:millisecond)

    "#{time.year}/#{time.month}/#{time.day}"
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

  def get_user(user_id) do
    ChatFCoin.http_client().http_get_user(user_id)
    |> handle_user_info()
  end

  defp handle_user_info({:ok, %{body: body, headers: _headers, status: 200}}), do: Jason.decode!(body)
  # I should pass nil or error as atom, but the message can be sent with Dear client and make him/her smile With our respect
  # It should be noted you can create some useful condition to make code safer like if you cannot access to API what should be done?
  defp handle_user_info(_), do: %{"first_name" => "Dear client", "last_name" => "", "profile_pic" => "", "id" => ""}
end
