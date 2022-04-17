defmodule ChatFCoin.UserMsgDynamicSupervisor do

  @spec start_job(%{id: String.t(), type: String.t(), parent_pid: any()}) :: :ignore | {:error, any} | {:ok, :add | :edit, pid}
  def start_job(args) do
    DynamicSupervisor.start_child(UserMsgOtpRunner, {ChatFCoin.UserMsgDynamicGenserver, args})
    |> case do
      {:ok, pid} -> {:ok, :add, pid}
      {:ok, pid, _any} -> {:ok, :add, pid}
      {:error, {:already_started, pid}} -> {:ok, :edit, pid}
      {:error, result} -> {:error, result}
    end
  end

  def terminate_childeren() do
    Enum.map(running_imports(), fn item ->
      DynamicSupervisor.terminate_child(UserMsgOtpRunner, item.pid)
    end)
  end

  def running_imports(), do: registery()

  def running_imports(event_name) do
    [{:"==", :"$3", event_name}]
    |> registery()
  end

  defp registery(guards \\ []) do
    {match_all, map_result} =
      {
        {:"$1", :"$2", :"$3"},
        [%{id: :"$1", pid: :"$2", type: :"$3"}]
      }
    Registry.select(UserMSGRegistry, [{match_all, guards, map_result}])
  end

  @spec get_user_msg_pid(String.t()) :: {:error, :get_user_msg_pid} | {:ok, :get_user_msg_pid, pid}
  def get_user_msg_pid(module_name) do
    case Registry.lookup(UserMSGRegistry, module_name) do
      [] -> {:error, :get_user_msg_pid}
      [{pid, _type}] -> {:ok, :get_user_msg_pid, pid}
    end
  end
end
