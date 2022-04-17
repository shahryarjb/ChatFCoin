defmodule ChatFCoin.UserMsgDynamicGenserver do
  use GenServer
  require Logger
  alias ChatFCoin.{UserMsgDynamicSupervisor, UserMsgDynamicGenserver}

  defstruct [:user_id, :user_info, :user_answers, :last_try, :parent_pid, social_network: :facebook]

  @type user_id() :: integer() | String.t()
  @type user_info() :: map()
  @type user_answers() :: [integer()]
  @type last_try() :: NaiveDateTime.t()
  @type parent_pid() :: pid() | nil
  @type social_network() :: :facebook, :telegram
  @type user_msg() :: %UserMsgDynamicGenserver{
    user_id: user_id(),
    user_info: user_info(),
    user_answers: user_answers(),
    last_try: last_try(),
    parent_pid: parent_pid()
  }
  @type t :: user_msg()

  # Sender
  def start_link(args) do
    {id, type, parent_pid} = {Map.get(args, :id), Map.get(args, :type), Map.get(args, :parent_pid)}
    GenServer.start_link(__MODULE__, default(id, type, parent_pid), name: via(id, type))
  end

  def child_spec(process_name) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [process_name]},
      restart: :transient,
      max_restarts: 4
    }
  end

  defp default(user_id, type, parent_pid) do
    %UserMsgDynamicGenserver{user_id: user_id, parent_pid: parent_pid, social_network: type, last_try: NaiveDateTime.utc_now()}
  end

  def push_call(%UserMsgDynamicGenserver{} = element) do
    case UserMsgDynamicSupervisor.start_job(%{id: element.user_id, type: element.social_network, parent_pid: element.parent_pid}) do
      {:ok, status, pid} ->
        if Mix.env() == :test, do: Logger.warn("#{element.user_info["first_name"]} is being pushed")
        GenServer.call(pid, {:push, status, element})
      {:error, result} ->  {:error, :push, result}
    end
  end

  def get(network: network_name) do
    case UserMsgDynamicSupervisor.get_user_msg_pid(network_name) do
      {:ok, :get_user_msg_pid, pid} -> GenServer.call(pid, {:pop, :network})
      {:error, :get_user_msg_pid} -> {:error, :get, :not_found}
    end
  end

  def get_all(network: network_name) do
    UserMsgDynamicSupervisor.running_imports(network_name) |> Enum.map(&get(network: &1.id))
  end

  def get_all() do
    UserMsgDynamicSupervisor.running_imports() |> Enum.map(&get(network: &1.id))
  end

  # Callbacks
  @impl true
  def init(%UserMsgDynamicGenserver{} = state) do
    if Mix.env == :test, do: MishkaInstaller.Database.Helper.get_parent_pid(state)
    Logger.info("#{Map.get(state, :user_id)} from #{Map.get(state, :social_network)} has started to be sending messages")
    {:ok, state, {:continue, {:user_evaluation}}}
  end

  @impl true
  def handle_continue({:user_evaluation}, %UserMsgDynamicGenserver{} = state) do
    {:noreply, state}
  end

  @impl true
  def handle_call({:push, _status, %UserMsgDynamicGenserver{} = element}, _from, %UserMsgDynamicGenserver{} = _state) do
    {:reply, element, element}
  end

  @impl true
  def handle_call({:pop, :network}, _from, %UserMsgDynamicGenserver{} = state) do
    {:reply, state, state}
  end

  defp via(id, value) do
    {:via, Registry, {UserMSGRegistry, id, value}}
  end
end
