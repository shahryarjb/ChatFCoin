defmodule ChatFCoin.Helper.HttpSenderMock do
  @behaviour ChatFCoin.Helper.HttpClientBehaviour

  @impl true
  def http_send_message(_body) do
    {:ok, %{}}
  end

  @impl true
  def http_get_user(_person_id) do
    {:ok, %{}}
  end

  @impl true
  def http_get_coins(_per_page) do
    {:ok, %{}}
  end

  @impl true
  def http_get_coin_history(_coin_id, _currency, _days) do
    {:ok, %{}}
  end
end
