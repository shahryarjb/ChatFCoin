defprotocol ChatFCoin.ChatBotControllerProtocol do
  @spec webhook(struct()) :: Plug.Conn.t()
  def webhook(args)
end
