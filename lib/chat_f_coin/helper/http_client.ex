defmodule ChatFCoin.Helper.HttpClient do
  @callback send_message(map(), binary) :: {:error, map()} | {:ok, map() | struct()}
  @callback get_user_info(binary, binary) :: {:error, map()} | {:ok, map() | struct()}
  @callback get_last_coins(integer(), binary, String.t(), String.t()) :: {:error, map()} | {:ok, map() | struct()}
  @callback get_coin_history(binary, binary, binary, integer(), String.t()) :: {:error, map()} | {:ok, map() | struct()}
end
