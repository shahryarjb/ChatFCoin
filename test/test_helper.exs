ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(ChatFCoin.Repo, :manual)
Mox.defmock(ChatFCoin.Helper.HttpSenderTestMock, for: ChatFCoin.Helper.HttpClient)
