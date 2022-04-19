defmodule ChatFCoin.Helper.HttpSender do
  @facebook_message_url "https://graph.facebook.com/v2.6/me/messages"
  @coin_url "https://api.coingecko.com/api/v3/coins"
  @request_name MyHttpClient

  @behaviour ChatFCoin.Helper.HttpClientBehaviour
  # If there is another chatbot like telegram, I prefer to change this HTTP sender module as helper not for specific social network
  # Not it is like a hardcode sender and it is not my type in coding
  @impl true
  def http_send_message(body, access_token \\ ChatFCoin.get_config(:facebook_chat_accsess_token)) do
    headers = [
      {"Content-type", "application/json"},
      {"Accept", "application/json"}
    ]
    Finch.build(:post, @facebook_message_url <> "?access_token=#{access_token}", headers, body |> Jason.encode!())
    |> Finch.request(@request_name)
  end

  # Ref: https://developers.facebook.com/docs/graph-api/reference/v2.6/user
  @impl true
  def http_get_user(person_id, access_token \\ ChatFCoin.get_config(:facebook_chat_accsess_token)) do
    url = "https://graph.facebook.com/v13.0/#{person_id}?access_token=#{access_token}"
    Finch.build(:get, url)
    |> Finch.request(@request_name)
  end

  @impl true
  def http_get_coins(per_page \\ 5) do
    url = "#{@coin_url}?per_page=#{per_page}"
    Finch.build(:get, url)
    |> Finch.request(@request_name)
  end

  @impl true
  def http_get_coin_history(coin_id, currency, days) do
    query =
      %{"id" => coin_id, "vs_currency" => currency, "days" => days, "interval" => "daily"}
      |> URI.encode_query
    url = "#{@coin_url}/bitcoin/market_chart?#{query}"
    Finch.build(:get, url)
    |> Finch.request(@request_name)
  end
end
