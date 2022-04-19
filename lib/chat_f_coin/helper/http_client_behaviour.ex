defmodule ChatFCoin.Helper.HttpClientBehaviour do
  @callback http_send_message(map()) :: {:error, map()} | {:ok, map() | struct()}
  @callback http_send_message(map(), binary) :: {:error, map()} | {:ok, map() | struct()}
  @callback http_get_user(binary) :: {:error, map()} | {:ok, map() | struct()}
  @callback http_get_user(binary, binary) :: {:error, map()} | {:ok, map() | struct()}
  @callback http_get_coins(integer()) :: {:error, map()} | {:ok, map() | struct()}
  @callback http_get_coin_history(binary, binary, integer()) :: {:error, map()} | {:ok, map() | struct()}

  @optional_callbacks http_send_message: 2, http_get_user: 2
end
