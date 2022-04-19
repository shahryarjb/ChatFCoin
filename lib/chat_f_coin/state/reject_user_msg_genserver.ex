defmodule ChatFCoin.RejectUserMsgGenserver do
  use GenServer
  require Logger

  use Timex

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(state) do
    Logger.info("Rejection Task of UserMessage was started")
    {:ok, state, 300000}  #5min
  end

  @impl true
  def handle_info(:timeout, state) do
    reject_expaierd_user_message()
    Logger.info("Rejection Task loop of UserMessage was reloaded")
    {:noreply, state, 300000}#5min
  end

  defp reject_expaierd_user_message() do
    ChatFCoin.UserMsgDynamicGenserver.get_all()
    |> Enum.map(fn x ->
      if Timex.diff(DateTime.utc_now, x.last_try, :day) >= 2, do: ChatFCoin.UserMsgDynamicGenserver.delete(user_id: x.user_id)
    end)
  end
end
