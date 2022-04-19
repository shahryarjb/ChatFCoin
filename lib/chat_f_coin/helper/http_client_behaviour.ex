defmodule ChatFCoin.Helper.HttpClientBehaviour do
  @callback http_send_message(map(), binary) :: {:error, map()} | {:ok, map() | struct()}
  @callback http_get_user(binary, binary) :: {:error, map()} | {:ok, map() | struct()}
  @callback http_get_coins(integer(), binary, String.t(), String.t()) :: {:error, map()} | {:ok, map() | struct()}
  @callback http_get_coin_history(binary, binary, binary, integer(), String.t()) :: {:error, map()} | {:ok, map() | struct()}
end
