defmodule ChatFCoin.Repo do
  use Ecto.Repo,
    otp_app: :chat_f_coin,
    adapter: Ecto.Adapters.Postgres
end
