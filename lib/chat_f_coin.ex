defmodule ChatFCoin do
  def get_config(item) do
    Application.get_env(:chat_f_coin, ChatFCoinWeb.Endpoint)[item]
  end

  def http_client() do
    Application.get_env(:chat_f_coin, :http_client)
  end
end
