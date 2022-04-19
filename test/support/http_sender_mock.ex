defmodule ChatFCoin.Helper.HttpSenderMock do
  @behaviour ChatFCoin.Helper.HttpClientBehaviour

  @impl true
  def http_send_message(_body, _token) do
    {:ok, %{}}
  end

  @impl true
  def http_get_user(_person_id, _token) do
    {:ok, %{}}
  end

  @impl true
  def http_get_coins(_per_page, _user_id, _first_name, _type) do
    {:ok, %{}}
  end

  @impl true
  def http_get_coin_history(_user_id, _coin_id, _currency, _days, _first_name) do
    {:ok, %{}}
  end
end
