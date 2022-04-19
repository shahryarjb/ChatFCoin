ExUnit.start()
Mox.defmock(ChatFCoin.Helper.HttpSenderTestMock, for: ChatFCoin.Helper.HttpClientBehaviour)
Application.put_env(:chat_f_coin, :http_client, ChatFCoin.Helper.HttpSenderTestMock)
